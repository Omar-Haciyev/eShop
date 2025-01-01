using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record VariationResponse(
    [property: JsonPropertyName("variation_code")] string VariationCode,
    [property: JsonPropertyName("additional_image")] string? AdditionalImage);