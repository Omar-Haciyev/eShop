using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;

namespace eShopEngine.API.Services.Interfaces;

public interface ISecurityService
{
    Task<CustomResponseModel<GenerateTokenResponse>> GenerateTokenAsync(string key);
    Task<CustomResponseModel<UserExistsResponse>> UserExistsAsync(string token,string email);
    Task<CustomResponseModel<string>> SignUpAsync(string token, SignUpRequest request);
    Task<CustomResponseModel<ChoiceResponse>> InsertChoiceUserAsync(string token,ChoiceRequest request);
    Task<CustomResponseModel<ResendOtpResponse>> ResendOtpCodeAsync(string token);
    Task<CustomResponseModel<ConfirmOtpResponse>> ConfirmOtpAsync(string token, ConfirmOtpRequest request);
    Task<CustomResponseModel<object>> SignInAsync(string token,SignInRequest request);
    Task<CustomResponseModel<RefreshTokenResponse>> RefreshTokenAsync(string token);
    Task<CustomResponseModel<ForgotPasswordResponse>> ForgotPasswordAsync(string token, ForgotPasswordRequest request);
    Task<CustomResponseModel<ForgotPasswordConfirmResponse>> ForgotPasswordConfirmOtpAsync(string token, ForgotPasswordConfirmRequest request);
    Task<CustomResponseModel<bool>>LogoutAsync (string token);
}