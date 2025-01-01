using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public class SignInResponse
{
    [JsonPropertyName("token")]
    public string Token { get; set; } = string.Empty;
    [JsonPropertyName("user_id")]
    public string UserId { get; set; } = string.Empty;
    [JsonPropertyName("role")]
    public string Role { get; set; } = string.Empty;
    [JsonPropertyName("expired_date")]
    public DateTime ExpiredDate { get; set; }
    [JsonPropertyName("password_hash")]
    public string PasswordHash { get; set; } 
}
