using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ChoiceResponse(
    [property: JsonPropertyName("user_email")]string UserEmail
);