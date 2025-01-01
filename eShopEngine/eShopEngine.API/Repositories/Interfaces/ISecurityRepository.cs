using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;

namespace eShopEngine.API.Repositories.Interfaces;

public interface ISecurityRepository
{
    Task<(int StatusCode, GenerateTokenResponse? Response)> GenerateTokenAsync(string platformKey);
    Task<string?> AuthorizationTokenAsync(string token);
    Task<bool> UserExistsAsync(string token,string email);
    Task<int> SignUpAsync(string token, SignUpRequest request,string otpCode);
    Task<string?> InsertChoiceUserAsync(string token,ChoiceRequest request,string otpCode);
    Task<string?> ResendOtpCodeAsync(string token,string otpCode);
    Task<(int StatusCode, ConfirmOtpResponse? Response)> ConfirmOtpAsync(string token, ConfirmOtpRequest request);
    Task<(int StatusCode, SignInResponse? Response)> SignInAsync(string token, SignInRequest request, string otpCode);
    Task<string?> RefreshTokenAsync(string token);
    Task<(int StatusCode, ForgotPasswordResponse? Response)> ForgotPasswordAsync(string token,ForgotPasswordRequest request,string otpCode);
    Task<string?> ForgotPasswordConfirmOtpAsync(string token, ForgotPasswordConfirmRequest request);
    Task<bool> LogoutAsync(string token);
}