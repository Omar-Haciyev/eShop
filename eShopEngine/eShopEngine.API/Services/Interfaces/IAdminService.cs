using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;

namespace eShopEngine.API.Services.Interfaces;

public interface IAdminService
{
    Task<CustomResponseModel<bool>> AddMainCategoryAsync(string token, string mainCategoryName);
    Task<CustomResponseModel<bool>> UpdateMainCategoryAsync(string token, int mainCategoryId, string name);
    Task<CustomResponseModel<bool>> DeleteMainCategoryAsync(string token, int mainCategoryId);
    Task<CustomResponseModel<bool>> AddCategoryAsync(string token, string categoryName);
    Task<CustomResponseModel<bool>> UpdateCategoryAsync(string token, int categoryId, string name);
    Task<CustomResponseModel<bool>> DeleteCategory(string token, int categoryId);
    Task<CustomResponseModel<bool>> AddSubCategoryAsync(string token, int categoryId, string subCategoryName);
    Task<CustomResponseModel<bool>> UpdateSubCategoryAsync(string token, int subCategoryId, string name);
    Task<CustomResponseModel<bool>> DeleteSubCategoryAsync(string token, int subCategoryId);
    Task<CustomResponseModel<bool>> CreateHierarchyAsync(string token, int[] mainCategoryIds, int[] subCategoryIds);

    Task<CustomResponseModel<bool>> UpdateHierarchyAsync(string token, int hierarchyId, int mainCategoryId,
        int categoryId, int subCategoryId);

    Task<CustomResponseModel<bool>> DeleteHierarchyAsync(string token, int hierarchyId);
    Task<CustomResponseModel<HierarchyListResponse>> GetHierarchyAsync(string token);
    Task<CustomResponseModel<object>> GetHierarchyAsyncV2(string token);
    Task<CustomResponseModel<bool>> AddProductAsync(string token, AddProductRequest request);

    Task<CustomResponseModel<bool>> AddProductImagesAsync(string token, string productVariationId,
        List<IFormFile> images);

    Task<CustomResponseModel<bool>> DeleteProductImagesAsync(string token, string productVariationId,
        string[] imageIdsToDelete);

    Task<CustomResponseModel<bool>> UpdateProductAsync(string token, UpdateProductRequest request);
    Task<CustomResponseModel<bool>> UpdateInventoryAsync(string token, string productVariationId, int quantity);
    Task<CustomResponseModel<bool>> AddProductVariationsAsync(string token, AddProductVariationRequest request);
}