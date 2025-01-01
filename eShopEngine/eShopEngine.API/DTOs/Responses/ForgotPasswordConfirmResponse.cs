using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ForgotPasswordConfirmResponse(
    [property: JsonPropertyName("token")]string Token,
    [property: JsonPropertyName("user_id")]string UserId,
    [property: JsonPropertyName("role")]string Role,
    [property: JsonPropertyName("expired_date")]DateTime ExpiredDate
);