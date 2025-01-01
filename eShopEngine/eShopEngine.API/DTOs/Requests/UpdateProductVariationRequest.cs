namespace eShopEngine.API.DTOs.Requests;

public record UpdateProductVariationRequest(
    string VariationCode,
    string Make,
    string Fabric,
    string Description,
    string ColorId,
    decimal Price
    );