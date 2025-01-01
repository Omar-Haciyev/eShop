using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record GenderFilterResponse(
    [property: JsonPropertyName("id")] int Id,
    [property: JsonPropertyName("name")] string Name);