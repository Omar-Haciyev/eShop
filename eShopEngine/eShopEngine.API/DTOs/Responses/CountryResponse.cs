using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record CountryResponse(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("country_name")]
    string CountryName);