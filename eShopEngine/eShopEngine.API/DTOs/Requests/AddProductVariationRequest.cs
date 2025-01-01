namespace eShopEngine.API.DTOs.Requests;

public record AddProductVariationRequest(
    string ProductId,
    string Make,
    string Fabric,
    string Description,
    string ColorId,
    decimal Price,
    int Quantity,
    string[] Sizes);