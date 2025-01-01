using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record RegionDto(
    [property: JsonPropertyName("region_name")]
    string RegionName,
    [property: JsonPropertyName("region_type")]
    string RegionType);