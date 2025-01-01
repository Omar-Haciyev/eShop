using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ImageResponse(
    [property: JsonPropertyName("url")] string Url
);