using System.ComponentModel.DataAnnotations;

namespace eShopEngine.API.DTOs.Requests;

public record UpdateUserRequest(
    string NewEmail,
    string PhoneNumber,
    string NewCountryId,
    string NewLocationId,
    string NewCity,
    [RegularExpression(@"^\d{5}$", ErrorMessage = "ZipCode must be exactly 5 digits.")]
    string NewZipCode
);