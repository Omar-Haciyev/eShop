using System.ComponentModel.DataAnnotations;

namespace eShopEngine.API.DTOs.Requests;

public record SignUpRequest(
    [EmailAddress(ErrorMessage = "Invalid email format.")]
    string Email,
    [MinLength(8, ErrorMessage = "Password must be at least 8 characters long.")]
    [RegularExpression(@"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$",
        ErrorMessage = "Password must be at least 8 characters long and contain at least one letter and one number.")]
    string Password
);