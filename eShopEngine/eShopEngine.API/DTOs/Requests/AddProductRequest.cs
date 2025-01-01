namespace eShopEngine.API.DTOs.Requests;

public record AddProductRequest(
    int MainCategoryId,
    int SubCategoryId,
    string ProductName,
    int GenderId,
    string Make,
    string Fabric,
    string Description,
    string ColorCode,
    decimal Price,
    int Quantity,
    string[] SizeList
);