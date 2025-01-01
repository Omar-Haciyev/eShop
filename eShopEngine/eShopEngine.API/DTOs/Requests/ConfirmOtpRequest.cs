using System.ComponentModel.DataAnnotations;

namespace eShopEngine.API.DTOs.Requests;

public class ConfirmOtpRequest
{
    [Required(ErrorMessage = "OTP is required.")]
    [StringLength(6, MinimumLength = 6, ErrorMessage = "OTP must be exactly 6 digits.")]
    [RegularExpression(@"^\d{6}$", ErrorMessage = "OTP must be numeric.")]
    public string EnteredOtpCode { get; set; } = string.Empty;
}