using System.Text.Json;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using eShopEngine.API.Services.Interfaces;

namespace eShopEngine.API.Services.Classes;

public class UserService(IUserRepository repository) : IUserService
{
    public async Task<CustomResponseModel<List<MainCategoryResponse>>> GetMainCategoriesAsync(string token)
    {
        var jsonResult = await repository.GetMainCategoriesAsync(token);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<MainCategoryResponse>>(404, "No categories found or invalid token.");
        }

        var categories = JsonSerializer.Deserialize<List<MainCategoryResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<MainCategoryResponse>>(404, "No categories found or invalid token.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<MainCategoryResponse>> GetMainCategoryByIdAsync(string token,
        int mainCategoryId)
    {
        var res = await repository.GetMainCategoryByIdAsync(token, mainCategoryId);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<MainCategoryResponse>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<MainCategoryResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<MainCategoryResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<CategoryResponse>>> GetCategoriesAsync(string token)
    {
        var jsonResult = await repository.GetCategoriesAsync(token);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<CategoryResponse>>(404, "No categories found or invalid token.");
        }

        var categories = JsonSerializer.Deserialize<List<CategoryResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<CategoryResponse>>(404, "No categories found or invalid token.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<CategoryResponse>> GetCategoryByIdAsync(string token,
        int categoryId)
    {
        var res = await repository.GetCategoryByIdAsync(token, categoryId);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<CategoryResponse>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<CategoryResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<CategoryResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<SubCategoryResponse>>> GetSubCategoriesAsync(string token)
    {
        var jsonResult = await repository.GetSubCategoriesAsync(token);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<SubCategoryResponse>>(404, "No categories found or invalid token.");
        }

        var categories = JsonSerializer.Deserialize<List<SubCategoryResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<SubCategoryResponse>>(404, "No categories found or invalid token.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<SubCategoryResponse>> GetSubCategoryByIdAsync(string token,
        int subCategoryId)
    {
        var res = await repository.GetSubCategoryByIdAsync(token, subCategoryId);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<SubCategoryResponse>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<SubCategoryResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<SubCategoryResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<CategoryByMainCategoryResponse>>> GetCategoriesByMainCategoryIdAsync(
        string token, int mainCategoryId)
    {
        var jsonResult = await repository.GetCategoriesByMainCategoryIdAsync(token, mainCategoryId);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<CategoryByMainCategoryResponse>>(404,
                "No categories found or invalid token.");
        }

        var categories = JsonSerializer.Deserialize<List<CategoryByMainCategoryResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<CategoryByMainCategoryResponse>>(404,
                "No categories found or invalid token.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<List<MainCategoryResponseV2>>>
        GetCategoriesAndSubCategoriesByMainCategoryIdAsync(string token, int mainCategoryId)
    {
        var jsonResult = await repository.GetCategoriesAndSubCategoriesByMainCategoryIdAsync(token, mainCategoryId);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<MainCategoryResponseV2>>(404, "No categories found or invalid token.");
        }

        var categories = JsonSerializer.Deserialize<List<MainCategoryResponseV2>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<MainCategoryResponseV2>>(404, "No categories found or invalid token.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<List<ProductResponse>>> GetProductsAsync(string token,
        GetProductRequest request)
    {
        var jsonResult = await repository.GetProductsAsync(token, request);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<ProductResponse>>(404, "No categories found.");
        }

        var categories = JsonSerializer.Deserialize<List<ProductResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<ProductResponse>>(404, "No categories found.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<ProductPreviewResponse>> GetProductPreviewAsync(string token,
        string variationCode)
    {
        var res = await repository.GetProductPreviewAsync(token, variationCode);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<ProductPreviewResponse>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<ProductPreviewResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<ProductPreviewResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<SubCategoryResponseWrapper>> GetSubCategoriesByFilterAsync(string token,
        GetSubCategoriesByFilterRequest request)
    {
        var res = await repository.GetSubCategoriesByFilterAsync(token, request);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<SubCategoryResponseWrapper>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<SubCategoryResponseWrapper>(res);

        return jsonRes == null
            ? ResponseHelper.Error<SubCategoryResponseWrapper>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<GenderFilterResponse>>> GetGendersByFilterAsync(string token)
    {
        var jsonResult = await repository.GetGendersByFilterAsync(token);

        if (string.IsNullOrEmpty(jsonResult))
        {
            return ResponseHelper.Error<List<GenderFilterResponse>>(404, "No categories found.");
        }

        var categories = JsonSerializer.Deserialize<List<GenderFilterResponse>>(jsonResult);

        if (categories == null || categories.Count == 0)
        {
            return ResponseHelper.Error<List<GenderFilterResponse>>(404, "No categories found.");
        }

        return ResponseHelper.Success(categories);
    }

    public async Task<CustomResponseModel<ProductResponseV2>> GetProductInfoAsync(string token, string variationCode)
    {
        var res = await repository.GetProductInfoAsync(token, variationCode);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<ProductResponseV2>(500, "Error while getting Main Category.");

        var jsonRes = JsonSerializer.Deserialize<ProductResponseV2>(res);

        return jsonRes == null
            ? ResponseHelper.Error<ProductResponseV2>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<ProductReviewsResponse?>> GetProductReviewsAsync(string token,
        string variationCode, int page, int pageSize)
    {
        var jsonResult = await repository.GetProductReviewsAsync(token, variationCode, page, pageSize);

        if (string.IsNullOrEmpty(jsonResult))
            return ResponseHelper.Error<ProductReviewsResponse>(500, "Error while getting product info.");

        var jsonRes = JsonSerializer.Deserialize<ProductReviewsResponse>(jsonResult);

        return jsonRes == null
            ? ResponseHelper.Error<ProductReviewsResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> AddOrUpdateReviewAsync(string token, string variationCode, int rating,
        string comment)
    {
        bool isSuccess = await repository.AddOrUpdateReviewAsync(token, variationCode, rating, comment);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> ToggleFavoriteAsync(string token, string variationCode)
    {
        bool isSuccess = await repository.ToggleFavoriteAsync(token, variationCode);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<object>> GetFavoritesAsync(string token, int page, int pageSize)
    {
        var res = await repository.GetFavoritesAsync(token, page, pageSize);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<object>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<object>(res);

        return jsonRes == null
            ? ResponseHelper.Error<object>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<SizesResponse>>> GetAvailableSizesAsync(string token,
        string variationCode)
    {
        var res = await repository.GetAvailableSizesAsync(token, variationCode);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<SizesResponse>>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<List<SizesResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<SizesResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<CountryResponse>>> GetCountriesAsync(string token)
    {
        var res = await repository.GetCountriesAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<CountryResponse>>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<List<CountryResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<CountryResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<LocationResponse>>> GetLocationsByCountryAsync(string token,
        string countryId)
    {
        var res = await repository.GetLocationsByCountryAsync(token, countryId);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<LocationResponse>>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<List<LocationResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<LocationResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<List<CountryWithRegionsDto>>> GetCountriesAndRegionsAsync(string token)
    {
        var res = await repository.GetCountriesAndRegionsAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<CountryWithRegionsDto>>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<List<CountryWithRegionsDto>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<CountryWithRegionsDto>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<UserInfoResponse>> GetUserInfoAsync(string token)
    {
        var res = await repository.GetUserInfoAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<UserInfoResponse>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<UserInfoResponse>(res);

        return jsonRes == null
            ? ResponseHelper.Error<UserInfoResponse>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> UpdateUserAsync(string token, UpdateUserRequest request)
    {
        bool isSuccess = await repository.UpdateUserAsync(token, request);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> ChangePasswordAsync(string token, UpdatePasswordRequest request)
    {
        int resultCode = await repository.ChangePasswordAsync(token, request);

        return resultCode switch
        {
            200 => ResponseHelper.Success(true),
            401 => ResponseHelper.Error<bool>(401, "Unauthorized: Invalid token."),
            403 => ResponseHelper.Error<bool>(403, "Forbidden: Insufficient permissions."),
            400 => ResponseHelper.Error<bool>(400, "Bad Request: Current password is incorrect."),
            422 => ResponseHelper.Error<bool>(422, "Passwords don't match.."),
            _ => ResponseHelper.Error<bool>(500, "Internal Server Error: Password change failed.")
        };
    }

    public async Task<CustomResponseModel<bool>> AddAddressAsync(string token, AddAddressRequest addressRequest)
    {
        bool isSuccess = await repository.AddAddressAsync(token, addressRequest);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<List<object>>> GetAddressesAsync(string token)
    {
        var res = await repository.GetAddressesAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<object>>(404, "Not Found.");

        var jsonRes = JsonSerializer.Deserialize<List<object>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<object>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> UpdateAddressAsync(string token, string addressId,
        UpdateAddressRequest request)
    {
        bool isSuccess = await repository.UpdateAddressAsync(token, addressId, request);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteAddressAsync(string token, string addressId)
    {
        bool isSuccess = await repository.DeleteAddressAsync(token, addressId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> AddBankCardAsync(string token, AddBankCardRequest bankCardRequest)
    {
        bool isSuccess = await repository.AddBankCardAsync(token, bankCardRequest);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<List<BankCardResponse>>> GetBankCardsAsync(string token)
    {
        var res = await repository.GetBankCardsAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<BankCardResponse>>(404, "Not found.");

        var jsonRes = JsonSerializer.Deserialize<List<BankCardResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<BankCardResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> UpdateBankCardAsync(string token, string bankCardId,
        UpdateBankCardRequest updateBankCardRequest)
    {
        bool isSuccess = await repository.UpdateBankCardAsync(token, bankCardId, updateBankCardRequest);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> DeleteBankCardAsync(string token, string bankCardId)
    {
        bool isSuccess = await repository.DeleteBankCardAsync(token, bankCardId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<List<ProductResponse>>> SearchAsync(string token, SearchRequest request)
    {
        var res = await repository.SearchAsync(token, request);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<ProductResponse>>(500, "Error.");

        var jsonRes = JsonSerializer.Deserialize<List<ProductResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<ProductResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> AddToCartAsync(string token, string variationCode, string sizeId)
    {
        bool isSuccess = await repository.AddToCartAsync(token, variationCode, sizeId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<List<CartResponse>>> ViewCartAsync(string token)
    {
        var res = await repository.ViewCartAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<CartResponse>>(404, "Not found.");
        //return ResponseHelper.Success(new List<CartResponse>());

        var jsonRes = JsonSerializer.Deserialize<List<CartResponse>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<CartResponse>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }

    public async Task<CustomResponseModel<bool>> UpdateCartItemQuantityAsync(string token, string cartItemId,
        int quantity)
    {
        bool isSuccess = await repository.UpdateCartItemQuantityAsync(token, cartItemId, quantity);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<bool>> ToggleIsSelectedAsync(string token, string cartItemId)
    {
        bool isSuccess = await repository.ToggleIsSelectedAsync(token, cartItemId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }

    public async Task<CustomResponseModel<decimal>> CalculateCartTotalAsync(string token, string promoCodeId)
    {
        var res = await repository.CalculateCartTotalAsync(token, promoCodeId);

        return ResponseHelper.Success(res);
    }

    public async Task<CustomResponseModel<bool>> ValidatePromoCodeAsync(string token, string promoCodeId)
    {
        bool isSuccess = await repository.ValidatePromoCodeAsync(token, promoCodeId);
        
        return ResponseHelper.Success(isSuccess);
    }

    public async Task<CustomResponseModel<bool>> CheckoutAsync(string token, string promoCodeId, string addressId,
        string bankCardId)
    {
        bool isSuccess = await repository.CheckoutAsync(token, promoCodeId, addressId, bankCardId);

        if (isSuccess)
        {
            return ResponseHelper.Success(isSuccess);
        }

        return ResponseHelper.Error<bool>(
            400,
            "Error."
        );
    }
    
    public async Task<CustomResponseModel<List<object>>> OrdersAsync(string token)
    {
        var res = await repository.OrdersAsync(token);

        if (string.IsNullOrEmpty(res))
            return ResponseHelper.Error<List<object>>(404, "Not found.");

        var jsonRes = JsonSerializer.Deserialize<List<object>>(res);

        return jsonRes == null
            ? ResponseHelper.Error<List<object>>(500, "Error deserializing response.")
            : ResponseHelper.Success(jsonRes);
    }
    
    public async Task<CustomResponseModel<bool>> DeleteAccountAsync(string token)
    {
        bool isSuccess = await repository.DeleteAccountAsync(token);

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