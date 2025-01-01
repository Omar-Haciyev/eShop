namespace eShopEngine.API.DTOs.Requests;

public record GetSubCategoriesByFilterRequest(
    int? MainCategoryId,
    int CategoryId,
    int[]? ClothingGenderId);