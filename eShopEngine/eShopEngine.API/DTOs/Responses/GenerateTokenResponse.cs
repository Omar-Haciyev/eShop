using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record GenerateTokenResponse(
    [property: JsonPropertyName("token")] string? Token,
    [property: JsonPropertyName("role")] string? Role,
    [property: JsonPropertyName("expired_date")]
    DateTime? ExpiredDate,
    [property: JsonPropertyName("error_msg")]
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    string? ErrorMsg
);