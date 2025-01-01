using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public class RefreshTokenResponse
{
    [JsonPropertyName("token")]
    public string Token { get; set; } = string.Empty;

    [JsonPropertyName("userID")]
    public string UserId { get; set; } = string.Empty;

    [JsonPropertyName("role")]
    public string Role { get; set; } = string.Empty;

    [JsonPropertyName("expiringDate")]
    public DateTime ExpiringDate { get; set; }
}