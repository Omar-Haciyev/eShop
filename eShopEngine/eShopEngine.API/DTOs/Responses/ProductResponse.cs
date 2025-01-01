using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ProductResponse(
    [property: JsonPropertyName("product_id")] string ProductId,
    [property: JsonPropertyName("product_name")] string ProductName,
    [property: JsonPropertyName("clothing_gender_id")] int? ClothingGenderId,
    [property: JsonPropertyName("main_category_name")] string MainCategoryName,
    [property: JsonPropertyName("category_name")] string CategoryName,
    [property: JsonPropertyName("gender_name")] string GenderName,
    [property: JsonPropertyName("colors")] int Colors,
    [property: JsonPropertyName("price")] decimal Price,
    [property: JsonPropertyName("promo_code")] string? PromoCode,
    [property: JsonPropertyName("promo_discount")] decimal PromoDiscount,
    [property: JsonPropertyName("Image")] string? Image,
    [property: JsonPropertyName("variations")] List<VariationResponse> Variations);