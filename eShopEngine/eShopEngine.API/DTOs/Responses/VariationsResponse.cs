using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record VariationsResponse(
    [property: JsonPropertyName("variation_code")]
    string VariationCode);