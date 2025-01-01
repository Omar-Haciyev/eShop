using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Requests;

public record UpdatePasswordRequest(
    string CurrentPassword,
    string NewPassword,
    string ConfirmPassword);