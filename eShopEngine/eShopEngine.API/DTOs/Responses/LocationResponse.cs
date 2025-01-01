using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record LocationResponse(
    [property: JsonPropertyName("location_id")]
    string LocationId,
    [property: JsonPropertyName("location_name")]
    string LocationName,
    [property: JsonPropertyName("location_type")]
    string LocationType);