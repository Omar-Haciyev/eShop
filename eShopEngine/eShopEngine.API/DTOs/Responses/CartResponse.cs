using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record CartResponse(
    [property: JsonPropertyName("cart_item_id")]
    string СartItemId,
    [property: JsonPropertyName("product_variation_id")]
    string ProductVariationId,
    [property: JsonPropertyName("product_name")]
    string ProductName,
    [property: JsonPropertyName("main_category")]
    string MainCategory,
    [property: JsonPropertyName("color")] string Color,
    [property: JsonPropertyName("size")] string Size,
    [property: JsonPropertyName("quantity")]
    int Quantity,
    [property: JsonPropertyName("price")] decimal Price,
    [property: JsonPropertyName("first_image")]
    string FirstImage,
    [property: JsonPropertyName("is_selected")]
    bool IsSelected);