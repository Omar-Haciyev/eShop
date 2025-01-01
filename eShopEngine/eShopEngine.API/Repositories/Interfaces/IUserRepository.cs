using eShopEngine.API.DTOs.Requests;

namespace eShopEngine.API.Repositories.Interfaces;

public interface IUserRepository
{
    Task<string?> GetMainCategoriesAsync(string token);
    Task<string?> GetMainCategoryByIdAsync(string token, int mainCategoryId);
    Task<string?> GetCategoriesAsync(string token);
    Task<string?> GetCategoryByIdAsync(string token, int categoryId);
    Task<string?> GetSubCategoriesAsync(string token);
    Task<string?> GetSubCategoryByIdAsync(string token, int subCategoryId);
    Task<string?> GetCategoriesByMainCategoryIdAsync(string token, int mainCategoryId);
    Task<string?> GetCategoriesAndSubCategoriesByMainCategoryIdAsync(string token, int mainCategoryId);
    Task<string?> GetProductsAsync(string token, GetProductRequest request);
    Task<string?> GetProductPreviewAsync(string token, string variationCode);
    Task<string?> GetSubCategoriesByFilterAsync(string token, GetSubCategoriesByFilterRequest request);
    Task<string?> GetGendersByFilterAsync(string token);
    Task<string?> GetProductInfoAsync(string token, string variationCode);
    Task<string?> GetProductReviewsAsync(string token, string variationCode, int page, int pageSize);
    Task<bool> AddOrUpdateReviewAsync(string token, string variationCode, int rating, string comment);
    Task<bool> ToggleFavoriteAsync(string token, string variationCode);
    Task<string?> GetFavoritesAsync(string token, int page, int pageSize);
    Task<string?> GetAvailableSizesAsync(string token, string variationCode);
    Task<string?> GetCountriesAsync(string token);
    Task<string?> GetLocationsByCountryAsync(string token, string countryId);
    Task<string?> GetCountriesAndRegionsAsync(string token);
    Task<string?> GetUserInfoAsync(string token);
    Task<bool> UpdateUserAsync(string token, UpdateUserRequest request);
    Task<string?> GetStoredPasswordAsync(string token);
    Task<int> ChangePasswordAsync(string token, UpdatePasswordRequest request);
    Task<bool> AddAddressAsync(string token, AddAddressRequest addressRequest);
    Task<string?> GetAddressesAsync(string token);
    Task<bool> UpdateAddressAsync(string token, string addressId, UpdateAddressRequest request);
    Task<bool> DeleteAddressAsync(string token, string addressId);
    Task<bool> AddBankCardAsync(string token, AddBankCardRequest bankCardRequest);
    Task<string?> GetBankCardsAsync(string token);
    Task<bool> UpdateBankCardAsync(string token, string bankCardId, UpdateBankCardRequest updateBankCardRequest);
    Task<bool> DeleteBankCardAsync(string token, string bankCardId);
    Task<string?> SearchAsync(string token, SearchRequest request);
    Task<bool> AddToCartAsync(string token, string variationCode, string sizeId);
    Task<string?> ViewCartAsync(string token);
    Task<bool> UpdateCartItemQuantityAsync(string token, string cartItemId, int quantity);
    Task<bool> ToggleIsSelectedAsync(string token, string cartItemId);
    Task<decimal> CalculateCartTotalAsync(string token, string promoCodeId);
    Task<bool> ValidatePromoCodeAsync(string token, string promoCodeId);
    Task<bool> CheckoutAsync(string token, string promoCodeId, string addressId, string bankCardId);
    Task<string?> OrdersAsync(string token);
    Task<bool> DeleteAccountAsync(string token);
}