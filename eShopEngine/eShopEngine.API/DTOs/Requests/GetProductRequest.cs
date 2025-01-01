namespace eShopEngine.API.DTOs.Requests;

public record GetProductRequest(
    int MainCategoryId,
    int CategoryId,
    int? SubCategoryId,
    int[]? ClothingGenderId,
    int SortId,
    int? PriceRangeId,
    int[]? ColorId,
    int PageNumber = 1,
    int PageSize = 15);