namespace eShopEngine.API.DTOs.Requests;

public record UpdateProductRequest(
    string ProductId,
    int MainCategoryId,
    int SubCategoryId,
    string ProductName,
    int GenderId);