using System.Data;
using System.Text;
using System.Text.Json;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using Microsoft.Data.SqlClient;
using WebExtensions.Helpers;

namespace eShopEngine.API.Repositories.Classes;

public class SecurityRepository(string connectionString) : RepositoryHelper(connectionString), ISecurityRepository
{
    public async Task<(int StatusCode, GenerateTokenResponse? Response)> GenerateTokenAsync(string platformKey)
    {
        await using var connection =
            new SqlConnection("Server=_THEHACIYEV;Database=eCommerceDb;Integrated Security=SSPI;Encrypt=False;");

        await using var command = new SqlCommand("sp_generate_token", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add(new SqlParameter("@platform_key", platformKey));

        var statusCodeParam = new SqlParameter("@status_code", SqlDbType.Int) { Direction = ParameterDirection.Output };
        command.Parameters.Add(statusCodeParam);

        var sessionIdParam = new SqlParameter("@session_id", SqlDbType.Int) { Direction = ParameterDirection.Output };
        command.Parameters.Add(sessionIdParam);

        await connection.OpenAsync();

        await command.ExecuteNonQueryAsync();
        var statusCode = (int)(statusCodeParam.Value ?? 0);

        if (statusCode != 200) return (statusCode, null);

        int sessionId = (int)(sessionIdParam.Value ?? 0);

        await using var jsonCommand = new SqlCommand("sp_get_session_json", connection);
        jsonCommand.CommandType = CommandType.StoredProcedure;
        jsonCommand.Parameters.Add(new SqlParameter("@session_id", sessionId));

        var jsonResult = (string?)await jsonCommand.ExecuteScalarAsync();
        if (string.IsNullOrEmpty(jsonResult)) return (statusCode, null);

        var response = JsonSerializer.Deserialize<GenerateTokenResponse>(jsonResult);

        return (statusCode, response);
    }

    public async Task<string?> AuthorizationTokenAsync(string token)
    {
        Command.Name = "sp_validate_token_and_return_info";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> UserExistsAsync(string token, string email)
    {
        Command.Name = "sp_check_user_exists";
        Command.AddParameter("token", token);
        Command.AddParameter("email", email);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<int> SignUpAsync(string token, SignUpRequest request, string otpCode)
    {
        Command.Name = "sp_sign_up";
        Command.AddParameter("token", token);
        Command.AddParameter("email", request.Email);
        Command.AddParameter("password", request.Password);
        Command.AddParameter("otp_code", otpCode);

        Command.ReturnValue = new ReturnValueOption("status_code", SqlDbType.Int);

        return await base.ExecuteCommandAsync<int>();
    }

    public async Task<string?> InsertChoiceUserAsync(string token, ChoiceRequest request, string otpCode)
    {
        Command.Name = "sp_insert_choice_user";
        Command.AddParameter("token", token);
        Command.AddParameter("otp_code", otpCode);
        Command.AddParameter("choice", request.Choice);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> ResendOtpCodeAsync(string token, string otpCode)
    {
        Command.Name = "sp_resend_otp_code";
        Command.AddParameter("token", token);
        Command.AddParameter("otp_code", otpCode);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<(int StatusCode, ConfirmOtpResponse? Response)> ConfirmOtpAsync(string token,
        ConfirmOtpRequest request)
    {
        await using var connection =
            new SqlConnection("Server=_THEHACIYEV;Database=eCommerceDb;Integrated Security=SSPI;Encrypt=False;");
        await using var command = new SqlCommand("sp_confirm_otp", connection);
        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add(new SqlParameter("@token", token));
        command.Parameters.Add(new SqlParameter("@entered_otp_code", request.EnteredOtpCode));

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();
        if (!reader.HasRows)
            return (404, null);

        var jsonResult = new StringBuilder();
        while (await reader.ReadAsync())
            jsonResult.Append(reader.GetString(0));

        if (string.IsNullOrEmpty(jsonResult.ToString()))
            return (500, null);

        var jsonDoc = JsonDocument.Parse(jsonResult.ToString());
        var statusCode = jsonDoc.RootElement.GetProperty("status_code").GetInt32();

        var responseJson = jsonDoc.RootElement.GetRawText();
        var response = JsonSerializer.Deserialize<ConfirmOtpResponse>(responseJson);

        return (statusCode, response);
    }

    public async Task<(int StatusCode, SignInResponse? Response)> SignInAsync(string token, SignInRequest request,
        string otpCode)
    {
        await using var connection =
            new SqlConnection("Server=_THEHACIYEV;Database=eCommerceDb;Integrated Security=SSPI;Encrypt=False;");
        await using var command = new SqlCommand("sp_sign_in", connection)
            { CommandType = CommandType.StoredProcedure };
        
        await connection.OpenAsync();

        await using var passwordCommand = new SqlCommand(
            "SELECT TOP 1 password_hash FROM dbo.user_accounts WHERE email = @Email ORDER BY id DESC",
            connection);
        passwordCommand.Parameters.AddWithValue("@Email", request.Email);

        var passwordHash = (string?)await passwordCommand.ExecuteScalarAsync();
        if (passwordHash == null)
        {
            return (404, null);  
        }

        var isPasswordValid = PasswordHasher.VerifyPassword(request.Password, passwordHash);
        if (!isPasswordValid)
        {
            return (401, null);  
        }

        command.Parameters.AddWithValue("@token", token);
        command.Parameters.AddWithValue("@email", request.Email);
        command.Parameters.AddWithValue("@otp_code", otpCode);
        command.Parameters.AddWithValue("@remember_me", request.RememberMe);

        await using var reader = await command.ExecuteReaderAsync();

        if (!reader.HasRows)
            return (404, null);

        var jsonResult = new StringBuilder();
        while (await reader.ReadAsync())
            jsonResult.Append(reader.GetString(0));

        if (string.IsNullOrEmpty(jsonResult.ToString()))
            return (500, null);

        var jsonDoc = JsonDocument.Parse(jsonResult.ToString());
        var statusCode = jsonDoc.RootElement.GetProperty("status").GetInt32();

        var responseJson = jsonDoc.RootElement.GetRawText();
        var response = JsonSerializer.Deserialize<SignInResponse>(responseJson);

        return (statusCode, response);
    }

    public async Task<string?> RefreshTokenAsync(string token)
    {
        Command.Name = "sp_refresh_token";
        Command.AddParameter("remember_me_token", token);

        var jsonResponse = await base.ExecuteCommandAsync<string>();

        if (string.IsNullOrEmpty(jsonResponse))
            return null;

        using var document = JsonDocument.Parse(jsonResponse);
        if (document.RootElement.TryGetProperty("status_code", out var statusCode) && statusCode.GetInt32() == 404)
            return null;

        return jsonResponse;
    }
    
    public async Task<(int StatusCode, ForgotPasswordResponse? Response)> ForgotPasswordAsync(string token,ForgotPasswordRequest request,string otpCode)
    {
        await using var connection = new SqlConnection("Server=_THEHACIYEV;Database=eCommerceDb;Integrated Security=SSPI;Encrypt=False;");
        await using var command = new SqlCommand("sp_forgot_password", connection)
        {
            CommandType = CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("@token", token);
        command.Parameters.AddWithValue("@otp_code", otpCode);
        command.Parameters.AddWithValue("@email", request.Email);

        await connection.OpenAsync();
        await using var reader = await command.ExecuteReaderAsync();

        if (!reader.HasRows)
            return (500, null);  

        var jsonResult = new StringBuilder();
        while (await reader.ReadAsync())
            jsonResult.Append(reader.GetString(0));

        if (string.IsNullOrEmpty(jsonResult.ToString()))
            return (500, null);  

        var jsonDoc = JsonDocument.Parse(jsonResult.ToString());
        var statusCode = jsonDoc.RootElement.GetProperty("status_code").GetInt32();

        if (statusCode != 200)
            return (statusCode, null);  

        var responseJson = jsonDoc.RootElement.GetRawText();
        var response = JsonSerializer.Deserialize<ForgotPasswordResponse>(responseJson);

        return (statusCode, response);
    }
    
    public async Task<string?> ForgotPasswordConfirmOtpAsync(string token, ForgotPasswordConfirmRequest request)
    {
        Command.Name = "sp_forgot_password_confirm_otp";
        Command.AddParameter("token", token);
        Command.AddParameter("entered_otp_code", request.EnteredOtpCode);
        Command.AddParameter("new_password", request.NewPassword);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> LogoutAsync(string token)
    {
        Command.Name = "sp_logout";
        Command.AddParameter("token", token);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
}