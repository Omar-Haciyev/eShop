using System.Text.Json;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using eShopEngine.API.Services.Interfaces;
using Microsoft.AspNetCore.StaticFiles;

namespace eShopEngine.API.Services.Classes;

public class AdminService(IAdminRepository repository, IBlobService blobService) : IAdminService
{
    public async Task<CustomResponseModel<bool>> AddMainCategoryAsync(string token, string mainCategoryName)
    {
        bool isSuccess = await repository.AddMainCategoryAsync(token, mainCategoryName);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> UpdateMainCategoryAsync(string token, int mainCategoryId, string name)
    {
        bool isSuccess = await repository.UpdateMainCategoryAsync(token, mainCategoryId, name);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteMainCategoryAsync(string token, int mainCategoryId)
    {
        bool isSuccess = await repository.DeleteMainCategoryAsync(token, mainCategoryId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> AddCategoryAsync(string token, string categoryName)
    {
        bool isSuccess = await repository.AddCategoryAsync(token, categoryName);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> UpdateCategoryAsync(string token, int categoryId, string name)
    {
        bool isSuccess = await repository.UpdateCategoryAsync(token, categoryId, name);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteCategory(string token, int categoryId)
    {
        bool isSuccess = await repository.DeleteCategory(token, categoryId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> AddSubCategoryAsync(string token, int categoryId,
        string subCategoryName)
    {
        bool isSuccess = await repository.AddSubCategoryAsync(token, categoryId, subCategoryName);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> UpdateSubCategoryAsync(string token, int subCategoryId, string name)
    {
        bool isSuccess = await repository.UpdateSubCategoryAsync(token, subCategoryId, name);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteSubCategoryAsync(string token, int subCategoryId)
    {
        bool isSuccess = await repository.DeleteSubCategoryAsync(token, subCategoryId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> CreateHierarchyAsync(string token, int[] mainCategoryIds,
        int[] subCategoryIds)
    {
        bool isSuccess = await repository.CreateHierarchyAsync(token, mainCategoryIds, subCategoryIds);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> UpdateHierarchyAsync(string token, int hierarchyId, int mainCategoryId,
        int categoryId, int subCategoryId)
    {
        bool isSuccess =
            await repository.UpdateHierarchyAsync(token, hierarchyId, mainCategoryId, categoryId, subCategoryId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteHierarchyAsync(string token, int hierarchyId)
    {
        bool isSuccess = await repository.DeleteHierarchyAsync(token, hierarchyId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<HierarchyListResponse>> GetHierarchyAsync(string token)
    {
        var res = await repository.GetHierarchyAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<HierarchyListResponse>(404, "Not found.");

        var jsonRes = JsonSerializer.Deserialize<HierarchyListResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<HierarchyListResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<object>> GetHierarchyAsyncV2(string token)
    {
        var res = await repository.GetHierarchyAsyncV2(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<object>(404, "Not found.");

        var jsonRes = JsonSerializer.Deserialize<object>(res);

        return jsonRes == null
            ? ResponseHelper.Error<object>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> AddProductAsync(string token, AddProductRequest request)
    {
        bool isSuccess = await repository.AddProductAsync(token, request);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> AddProductImagesAsync(string token, string productVariationId,
        List<IFormFile> images)
    {
        if (images.Count < 1 || images.Count > 5)
            return ResponseHelper.Error<bool>(400, "Image count must be between 1 and 5.");

        var allowedMimeTypes = new[] { "image/jpeg", "image/png", "image/gif" };
        var provider = new FileExtensionContentTypeProvider();

        foreach (var image in images)
        {
            Path.GetExtension(image.FileName).ToLowerInvariant();
            if (!provider.TryGetContentType(image.FileName, out var mimeType))
            {
                return ResponseHelper.Error<bool>(400, "Unable to determine MIME type.");
            }

            if (!allowedMimeTypes.Contains(mimeType.ToLowerInvariant()))
            {
                return ResponseHelper.Error<bool>(400,
                    "Invalid file type. Only JPEG, PNG, and GIF images are allowed.");
            }
        }

        var uploadedImageUrls = new string[images.Count];

        for (var i = 0; i < images.Count; i++)
        {
            var blobUrl = await blobService.UploadBlobAsync(images[i]);
            uploadedImageUrls[i] = blobUrl;
        }

        var isSuccess = await repository.AddProductImagesAsync(token, productVariationId, uploadedImageUrls);

        return isSuccess
            ? ResponseHelper.Success(isSuccess)
            : ResponseHelper.Error<bool>(400, "Failed to add product images.");
    }


    public async Task<CustomResponseModel<bool>> DeleteProductImagesAsync(string token, string productVariationId, string[] imageIdsToDelete)
    {
        if (string.IsNullOrEmpty(token))
            return ResponseHelper.Error<bool>(400, "Token cannot be null or empty.");

        if (string.IsNullOrEmpty(productVariationId))
            return ResponseHelper.Error<bool>(400, "Product variation ID cannot be null or empty.");

        if (imageIdsToDelete == null || imageIdsToDelete.Length == 0)
            return ResponseHelper.Error<bool>(400, "No image IDs provided for deletion.");

        try
        {
            // Получаем URL изображений из базы данных
            var imageUrls = await repository.GetImageUrlsAsync(productVariationId, imageIdsToDelete);

            if (imageUrls == null || imageUrls.Count == 0)
                return ResponseHelper.Error<bool>(400, "No images found for the provided IDs.");

            // Удаляем изображения из Blob Storage
            foreach (var url in imageUrls)
            {
                var deletionResult = await blobService.DeleteBlobAsync(url); // Здесь передаешь URL изображения
                if (!deletionResult)
                    return ResponseHelper.Error<bool>(400, $"Failed to delete image from Blob Storage: {url}");
            }

            // Удаляем записи из базы данных
            var sqlResult = await repository.DeleteProductImagesAsync(token, productVariationId, imageIdsToDelete);
            if (!sqlResult)
                return ResponseHelper.Error<bool>(400, "Failed to delete product images from the database.");

            return ResponseHelper.Success(true);
        }
        catch (Exception ex)
        {
            return ResponseHelper.Error<bool>(500, $"An error occurred: {ex.Message}");
        }
    }


    public async Task<CustomResponseModel<bool>> UpdateProductAsync(string token, UpdateProductRequest request)
    {
        bool isSuccess = await repository.UpdateProductAsync(token, request);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> UpdateInventoryAsync(string token, string productVariationId,
        int quantity)
    {
        bool isSuccess = await repository.UpdateInventoryAsync(token, productVariationId, quantity);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> AddProductVariationsAsync(string token,
        AddProductVariationRequest request)
    {
        bool isSuccess = await repository.AddProductVariationsAsync(token, request);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }
}