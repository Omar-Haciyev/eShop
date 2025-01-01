using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ConfirmOtpResponse(
    [property: JsonPropertyName("token")] string? Token,
    [property: JsonPropertyName("userID")] string? UserId,
    [property: JsonPropertyName("role")] string? Role,
    [property: JsonPropertyName("expiringDate")]
    DateTime? ExpiringDate);