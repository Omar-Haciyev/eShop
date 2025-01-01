using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ResendOtpResponse(
    [property: JsonPropertyName("user_id")]string UserId,
    [property: JsonPropertyName("code")]string Code,
    [property: JsonPropertyName("email")]string Email
);