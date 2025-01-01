using System.ComponentModel.DataAnnotations;

namespace eShopEngine.API.DTOs.Requests;

public record UserExistsRequest(
    [EmailAddress(ErrorMessage = "Invalid email format.")]
    string Email
);