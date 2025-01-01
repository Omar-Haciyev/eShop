using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;

namespace eShopEngine.API.Services.Interfaces;

public interface IUserService
{
    Task<CustomResponseModel<List<MainCategoryResponse>>> GetMainCategoriesAsync(string token);
    Task<CustomResponseModel<MainCategoryResponse>> GetMainCategoryByIdAsync(string token, int mainCategoryId);
    Task<CustomResponseModel<List<CategoryResponse>>> GetCategoriesAsync(string token);
    Task<CustomResponseModel<CategoryResponse>> GetCategoryByIdAsync(string token, int categoryId);
    Task<CustomResponseModel<List<SubCategoryResponse>>> GetSubCategoriesAsync(string token);
    Task<CustomResponseModel<SubCategoryResponse>> GetSubCategoryByIdAsync(string token, int subCategoryId);

    Task<CustomResponseModel<List<CategoryByMainCategoryResponse>>> GetCategoriesByMainCategoryIdAsync(string token,
        int mainCategoryId);

    Task<CustomResponseModel<List<MainCategoryResponseV2>>> GetCategoriesAndSubCategoriesByMainCategoryIdAsync(
        string token, int mainCategoryId);

    Task<CustomResponseModel<List<ProductResponse>>> GetProductsAsync(string token, GetProductRequest request);
    Task<CustomResponseModel<ProductPreviewResponse>> GetProductPreviewAsync(string token, string variationCode);

    Task<CustomResponseModel<SubCategoryResponseWrapper>> GetSubCategoriesByFilterAsync(string token,
        GetSubCategoriesByFilterRequest request);

    Task<CustomResponseModel<List<GenderFilterResponse>>> GetGendersByFilterAsync(string token);
    Task<CustomResponseModel<ProductResponseV2>> GetProductInfoAsync(string token, string variationCode);
    Task<CustomResponseModel<ProductReviewsResponse?>> GetProductReviewsAsync(string token, string variationCode,int page, int pageSize);
    Task<CustomResponseModel<bool>> AddOrUpdateReviewAsync(string token, string variationCode,int rating, string comment);
    Task<CustomResponseModel<bool>> ToggleFavoriteAsync(string token, string variationCode);
    Task<CustomResponseModel<object>> GetFavoritesAsync(string token, int page, int pageSize);
    Task<CustomResponseModel<List<SizesResponse>>> GetAvailableSizesAsync(string token, string variationCode);
    Task<CustomResponseModel<List<CountryResponse>>> GetCountriesAsync(string token);
    Task<CustomResponseModel<List<LocationResponse>>> GetLocationsByCountryAsync(string token,string countryId);
    Task<CustomResponseModel<List<CountryWithRegionsDto>>> GetCountriesAndRegionsAsync(string token);
    Task<CustomResponseModel<UserInfoResponse>> GetUserInfoAsync(string token);
    Task<CustomResponseModel<bool>> UpdateUserAsync(string token,UpdateUserRequest request);
    Task<CustomResponseModel<bool>> ChangePasswordAsync(string token,UpdatePasswordRequest request);
    Task<CustomResponseModel<bool>> AddAddressAsync(string token,AddAddressRequest addressRequest);
    Task<CustomResponseModel<List<object>>> GetAddressesAsync(string token);
    Task<CustomResponseModel<bool>> UpdateAddressAsync(string token, string addressId, UpdateAddressRequest request);
    Task<CustomResponseModel<bool>> DeleteAddressAsync(string token, string addressId);
    Task<CustomResponseModel<bool>> AddBankCardAsync(string token, AddBankCardRequest bankCardRequest);
    Task<CustomResponseModel<List<BankCardResponse>>> GetBankCardsAsync(string token);
    Task<CustomResponseModel<bool>> UpdateBankCardAsync(string token, string bankCardId, UpdateBankCardRequest updateBankCardRequest);
    Task<CustomResponseModel<bool>> DeleteBankCardAsync(string token, string bankCardId);
    Task<CustomResponseModel<List<ProductResponse>>> SearchAsync(string token,SearchRequest request);
    Task<CustomResponseModel<bool>> AddToCartAsync(string token,string variationCode,string sizeId);
    Task<CustomResponseModel<List<CartResponse>>> ViewCartAsync(string token);
    Task<CustomResponseModel<bool>> UpdateCartItemQuantityAsync(string token,string cartItemId,int quantity);
    Task<CustomResponseModel<bool>> ToggleIsSelectedAsync(string token,string cartItemId);
    Task<CustomResponseModel<decimal>> CalculateCartTotalAsync(string token,string promoCodeId);
    Task<CustomResponseModel<bool>> ValidatePromoCodeAsync(string token,string promoCodeId);
    Task<CustomResponseModel<bool>> CheckoutAsync(string token,string promoCodeId,string addressId,string bankCardId);
    Task<CustomResponseModel<List<object>>> OrdersAsync(string token);
    Task<CustomResponseModel<bool>> DeleteAccountAsync(string token);
}