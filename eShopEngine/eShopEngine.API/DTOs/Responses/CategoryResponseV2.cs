using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record CategoryResponseV2(
    [property: JsonPropertyName("category_id")] int CategoryId,
    [property: JsonPropertyName("category_name")] string CategoryName,
    [property: JsonPropertyName("sub_categories")] List<SubCategoryResponseV2> SubCategories);