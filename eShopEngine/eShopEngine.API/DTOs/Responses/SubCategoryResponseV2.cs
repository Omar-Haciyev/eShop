using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record SubCategoryResponseV2(
    [property: JsonPropertyName("sub_category_id")] int SubCategoryId,
    [property: JsonPropertyName("sub_category_name")] string SubCategoryName);