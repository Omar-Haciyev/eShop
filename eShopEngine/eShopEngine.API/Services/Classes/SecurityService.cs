using System.Text.Json;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using eShopEngine.API.Services.Interfaces;

namespace eShopEngine.API.Services.Classes;

public class SecurityService(IEmailService emailService, ISecurityRepository repository) : ISecurityService
{
    public async Task<CustomResponseModel<GenerateTokenResponse>> GenerateTokenAsync(string key)
    {
        if (string.IsNullOrEmpty(key) || key.Length != 12)
            return ResponseHelper.Error<GenerateTokenResponse>(400, "Key must be exactly 12 characters long");

        var (statusCode, result) = await repository.GenerateTokenAsync(key);

        return statusCode switch
        {
            200 => ResponseHelper.Success<GenerateTokenResponse>(result),
            400 => ResponseHelper.Error<GenerateTokenResponse>(400, "Invalid platform key."),
            _ => ResponseHelper.Error<GenerateTokenResponse>(500, "An unexpected error occurred.")
        };
    }

    public async Task<CustomResponseModel<UserExistsResponse>> UserExistsAsync(string token, string email)
    {
        bool exists = await repository.UserExistsAsync(token, email);
        return ResponseHelper.Success(new UserExistsResponse(exists));
    }

    public async Task<CustomResponseModel<string>> SignUpAsync(string token, SignUpRequest request)
    {
        var otpCode = OtpGenerator.GenerateOtpCode();
        var hashedPasswordRequest = request with { Password = PasswordHasher.HashPassword(request.Password) };

        int statusCode = await repository.SignUpAsync(token, hashedPasswordRequest, otpCode);

        if (statusCode == 200)
        {
            var emailSubject = "Your OTP Code";
            var emailBody = $"Your OTP code is: {otpCode}";

            await emailService.SendEmailAsync(request.Email, emailSubject, emailBody);

            return ResponseHelper.Success("OTP has been sent to your email.");
        }

        return statusCode switch
        {
            202 => ResponseHelper.Success("Choose to restore your account or create a new one."),
            409 => ResponseHelper.Error<string>(409, "A user with this email already exists."),
            403 => ResponseHelper.Error<string>(403, "This account is blocked."),
            429 => ResponseHelper.Error<string>(429, "Please try again later."),
            _ => ResponseHelper.Error<string>(500, "An unexpected error occurred.")
        };
    }

    public async Task<CustomResponseModel<ChoiceResponse>> InsertChoiceUserAsync(string token, ChoiceRequest request)
    {
        var otpCode = OtpGenerator.GenerateOtpCode();
        var result = await repository.InsertChoiceUserAsync(token, request, otpCode);

        if (string.IsNullOrEmpty(result))
            return ResponseHelper.Error<ChoiceResponse>(400, "An unexpected error occurred.");

        if (result.Contains("Operation not allowed"))
            return ResponseHelper.Error<ChoiceResponse>(403,
                "Operation is not allowed: account status is not suitable for this action.");

        if (result.Contains("expired"))
            return ResponseHelper.Error<ChoiceResponse>(410,
                "The confirmation code has expired. Please request a new code and try again.");

        var responseData = JsonSerializer.Deserialize<ChoiceResponse>(result);
        return ResponseHelper.Success(responseData);
    }

    public async Task<CustomResponseModel<ResendOtpResponse>> ResendOtpCodeAsync(string token)
    {
        var otpCode = OtpGenerator.GenerateOtpCode();
        var result = await repository.ResendOtpCodeAsync(token, otpCode);

        if (result.Contains("error_msg"))
            return ResponseHelper.Error<ResendOtpResponse>(400, "You can only resend OTP after 3 minutes.");

        var responseData = JsonSerializer.Deserialize<ResendOtpResponse>(result);

        if (responseData == null || string.IsNullOrEmpty(responseData.Email))
            return ResponseHelper.Error<ResendOtpResponse>(500, "Failed to retrieve email.");

        var emailSubject = "Your OTP Code";
        var emailBody = $"Your OTP code is: {otpCode}";

        await emailService.SendEmailAsync(responseData.Email, emailSubject, emailBody);

        return ResponseHelper.Success(responseData);
    }


    public async Task<CustomResponseModel<ConfirmOtpResponse>> ConfirmOtpAsync(string token, ConfirmOtpRequest request)
    {
        var (statusCode, result) = await repository.ConfirmOtpAsync(token, request);

        return statusCode switch
        {
            200 => ResponseHelper.Success(result),
            401 => ResponseHelper.Error<ConfirmOtpResponse>(401, "Invalid OTP. Please try again."),
            404 => ResponseHelper.Error<ConfirmOtpResponse>(404, "Token not found."),
            410 => ResponseHelper.Error<ConfirmOtpResponse>(410,
                "Time has expired. Please resend otp code and try again."),
            _ => ResponseHelper.Error<ConfirmOtpResponse>(500, "An unexpected error occurred.")
        };
    }

    public async Task<CustomResponseModel<object>> SignInAsync(string token, SignInRequest request)
    {
        var otpCode = OtpGenerator.GenerateOtpCode();

        var (statusCode, result) = await repository.SignInAsync(token, request, otpCode);

        if (statusCode == 401)
        {
            return ResponseHelper.Error<object>(401, "Incorrect password.");
        }

        if (statusCode != 200 && statusCode != 202)
        {
            return statusCode switch
            {
                403 => ResponseHelper.Error<object>(403, "This account is blocked."),
                404 => ResponseHelper.Error<object>(404, "User not found."),
                410 => ResponseHelper.Error<object>(410, "Account deleted."),
                _ => ResponseHelper.Error<object>(500, "An unexpected error occurred.")
            };
        }

        if (statusCode == 202)
        {
            var emailSubject = "Your OTP Code";
            var emailBody = $"Your OTP code is: {otpCode}";
            await emailService.SendEmailAsync(request.Email, emailSubject, emailBody);

            result.PasswordHash = null;
            return ResponseHelper.Success<object>("OTP has been sent to your email.");
        }

        if (statusCode == 200)
        {
            result.PasswordHash = null;
            return ResponseHelper.Success<object>(result);
        }

        return ResponseHelper.Error<object>(500, "Unexpected error during processing.");
    }


    public async Task<CustomResponseModel<RefreshTokenResponse>> RefreshTokenAsync(string token)
    {
        if (string.IsNullOrEmpty(token) || token.Length != 64)
            return ResponseHelper.Error<RefreshTokenResponse>(400, "Key must be exactly 20 characters long");

        var responseJson = await repository.RefreshTokenAsync(token);

        if (responseJson == null)
            return ResponseHelper.Error<RefreshTokenResponse>(404, "Invalid or expired remember-me token.");

        var response = JsonSerializer.Deserialize<RefreshTokenResponse>(responseJson);

        if (response == null)
            return ResponseHelper.Error<RefreshTokenResponse>(500, "Error processing the token data.");

        return ResponseHelper.Success(response);
    }

    public async Task<CustomResponseModel<ForgotPasswordResponse>> ForgotPasswordAsync(string token, ForgotPasswordRequest request)
    {
        var otpCode = OtpGenerator.GenerateOtpCode();
        var (statusCode, response) = await repository.ForgotPasswordAsync(token, request, otpCode);

        if (statusCode == 200 && response != null)
        {
            var emailSubject = "Your OTP Code";
            var emailBody = $"Your OTP code is: {otpCode}";
            await emailService.SendEmailAsync(request.Email, emailSubject, emailBody);

            return ResponseHelper.Success(response);
        }

        return statusCode switch
        {
            404 => ResponseHelper.Error<ForgotPasswordResponse>(404, "User not found."),
            403 => ResponseHelper.Error<ForgotPasswordResponse>(403, "Access denied."),
            429 => ResponseHelper.Error<ForgotPasswordResponse>(429, "Please wait before trying again."),
            _ => ResponseHelper.Error<ForgotPasswordResponse>(500, "An unexpected error occurred.")
        };
    }
    
    public async Task<CustomResponseModel<ForgotPasswordConfirmResponse>> ForgotPasswordConfirmOtpAsync(string token, ForgotPasswordConfirmRequest request)
    {
        string hashedPassword = PasswordHasher.HashPassword(request.NewPassword);

        var updatedRequest = request with { NewPassword = hashedPassword };
        
        string jsonResult = await repository.ForgotPasswordConfirmOtpAsync(token, updatedRequest);

        if (string.IsNullOrWhiteSpace(jsonResult))
        {
            return ResponseHelper.Error<ForgotPasswordConfirmResponse>(
                400,
                "An unexpected error occurred. Please try again."
            );
        }

        var response = JsonSerializer.Deserialize<ForgotPasswordConfirmResponse>(
            jsonResult, 
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
        );

        if (response != null && !string.IsNullOrEmpty(response.Token))
        {
            return ResponseHelper.Success(response);
        }

        var errorResponse = JsonSerializer.Deserialize<Dictionary<string, string>>(
            jsonResult, 
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
        );

        if (errorResponse != null && errorResponse.TryGetValue("error_msg", out var errorMessage))
        {
            return ResponseHelper.Error<ForgotPasswordConfirmResponse>(
                400,
                errorMessage
            );
        }

        return ResponseHelper.Error<ForgotPasswordConfirmResponse>(
            400,
            "Invalid response format."
        );
    }

    public async Task<CustomResponseModel<bool>> LogoutAsync(string token)
    {
        bool isSuccess = await repository.LogoutAsync(token);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Invalid token or session already terminated."
        );
    }
}