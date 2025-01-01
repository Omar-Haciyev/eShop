using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record SizesResponse([property: JsonPropertyName("id")] int SizeId,[property: JsonPropertyName("size")] string Size);
