using System.Text.Json.Serialization;
using Newtonsoft.Json;

namespace eShopEngine.API.DTOs.Responses;

public record CategoryByMainCategoryResponse(
    [property: JsonPropertyName("category_id")]
    int Id,
    [property: JsonPropertyName("category_name")]
    string Name);