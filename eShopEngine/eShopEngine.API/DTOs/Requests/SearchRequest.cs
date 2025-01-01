namespace eShopEngine.API.DTOs.Requests;

public record SearchRequest(
    int? MainCategoryId,
    int? CategoryId,
    int? SubCategoryId,
    string Fabric,
    string Keywords,
    string ProductName);