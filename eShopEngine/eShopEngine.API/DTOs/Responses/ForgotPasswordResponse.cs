using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ForgotPasswordResponse( [property: JsonPropertyName("msg")]string Message);