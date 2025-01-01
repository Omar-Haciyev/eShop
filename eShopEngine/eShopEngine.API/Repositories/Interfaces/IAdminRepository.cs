using eShopEngine.API.DTOs.Requests;

namespace eShopEngine.API.Repositories.Interfaces;

public interface IAdminRepository
{
    Task<bool> AddMainCategoryAsync(string token, string mainCategoryName);
    Task<bool> UpdateMainCategoryAsync(string token, int mainCategoryId, string name);
    Task<bool> DeleteMainCategoryAsync(string token, int mainCategoryId);
    Task<bool> AddCategoryAsync(string token, string categoryName);
    Task<bool> UpdateCategoryAsync(string token, int categoryId, string name);
    Task<bool> DeleteCategory(string token, int categoryId);
    Task<bool> AddSubCategoryAsync(string token, int categoryId,string subCategoryName);
    Task<bool> UpdateSubCategoryAsync(string token, int subCategoryId, string name);
    Task<bool> DeleteSubCategoryAsync(string token, int subCategoryId);
    Task<bool> CreateHierarchyAsync(string token,int[]mainCategoryIds,int[] subCategoryIds);    
    Task<bool> UpdateHierarchyAsync(string token,int hierarchyId ,int mainCategoryId,int categoryId,int subCategoryId);
    Task<bool> DeleteHierarchyAsync(string token,int hierarchyId);
    Task<string?>GetHierarchyAsync(string token);
    Task<string?>GetHierarchyAsyncV2(string token);
    Task<bool> AddProductAsync(string token,AddProductRequest request );
    Task<bool> AddProductImagesAsync(string token, string productVariationId, string[] imageUrls);
    Task<bool>DeleteProductImagesAsync(string token, string productVariationId,string []imageIdsToDelete);
    
    Task<List<string>> GetImageUrlsAsync(string productVariationId, string[] imageIdsToGet);
    Task<bool> UpdateProductAsync(string token,UpdateProductRequest request);
    Task<bool> UpdateInventoryAsync(string token,string productVariationId,int quantity);
    Task<bool> AddProductVariationsAsync(string token, AddProductVariationRequest request);
    
}