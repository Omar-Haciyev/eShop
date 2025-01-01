using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record SubCategoryResponseWrapper(
    [property: JsonPropertyName("sub_categories")]
    List<SubCategoryResponseV2> SubCategories);