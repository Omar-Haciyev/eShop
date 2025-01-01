using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record HierarchyResponse(
    [property: JsonPropertyName("id")]int Id,
    [property: JsonPropertyName("main_category_name")]string MainCategoryName,
    [property: JsonPropertyName("category_name")]string CategoryName,
    [property: JsonPropertyName("sub_category_name")]string SubCategoryName,
    [property: JsonPropertyName("status")]bool Status);