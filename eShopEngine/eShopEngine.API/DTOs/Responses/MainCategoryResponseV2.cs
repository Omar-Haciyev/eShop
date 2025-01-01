using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record MainCategoryResponseV2(
    [property: JsonPropertyName("main_category_id")] int MainCategoryId,
    [property: JsonPropertyName("main_category_name")] string MainCategoryName,
    [property: JsonPropertyName("categories")] List<CategoryResponseV2>Categories);