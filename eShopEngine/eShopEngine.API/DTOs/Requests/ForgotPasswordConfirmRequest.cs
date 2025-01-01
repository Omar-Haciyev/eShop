namespace eShopEngine.API.DTOs.Requests;

public record ForgotPasswordConfirmRequest(
    string EnteredOtpCode,
    string NewPassword);