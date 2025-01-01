using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record CountryWithRegionsDto(
    [property: JsonPropertyName("country_name")]
    string CountryName,
    [property: JsonPropertyName("location_type")]
    string LocationType,
    [property: JsonPropertyName("regions")]
    List<RegionDto> Regions);