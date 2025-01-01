using System.Data;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using WebExtensions.Helpers;

namespace eShopEngine.API.Repositories.Classes;

public class UserRepository(string connectionString) : RepositoryHelper(connectionString), IUserRepository
{
    public async Task<string?> GetMainCategoriesAsync(string token)
    {
        Command.Name = "sp_get_main_categories";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetMainCategoryByIdAsync(string token, int mainCategoryId)
    {
        Command.Name = "sp_get_main_category_by_id";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", mainCategoryId);
        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCategoriesAsync(string token)
    {
        Command.Name = "sp_get_categories";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCategoryByIdAsync(string token, int categoryId)
    {
        Command.Name = "sp_get_category_by_id";
        Command.AddParameter("token", token);
        Command.AddParameter("category_id", categoryId);
        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetSubCategoriesAsync(string token)
    {
        Command.Name = "sp_get_sub_categories";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetSubCategoryByIdAsync(string token, int subCategoryId)
    {
        Command.Name = "sp_get_sub_category_by_id";
        Command.AddParameter("token", token);
        Command.AddParameter("sub_category_id", subCategoryId);
        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCategoriesByMainCategoryIdAsync(string token, int mainCategoryId)
    {
        Command.Name = "sp_get_categories_by_main_category";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", mainCategoryId);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCategoriesAndSubCategoriesByMainCategoryIdAsync(string token, int mainCategoryId)
    {
        Command.Name = "sp_get_categories_and_sub_categories_by_main_category";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", mainCategoryId);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetProductsAsync(string token, GetProductRequest request)
    {
        Command.Name = "sp_get_products";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", request.MainCategoryId);
        Command.AddParameter("category_id", request.CategoryId);
        Command.AddParameter("sub_category_id", request.SubCategoryId);

        var genderListTable = TableHelper.ConvertToDataTable(request.ClothingGenderId);
        Command.AddParameter("clothing_gender_id", genderListTable);

        Command.AddParameter("page_number", request.PageNumber);
        Command.AddParameter("page_size", request.PageSize);
        Command.AddParameter("price_range_id", request.PriceRangeId);

        var colorListTable = TableHelper.ConvertToDataTable(request.ColorId);
        Command.AddParameter("color_ids", colorListTable);

        Command.AddParameter("sort_type_id", request.SortId);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetProductPreviewAsync(string token, string variationCode)
    {
        Command.Name = "sp_get_product_preview";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetSubCategoriesByFilterAsync(string token, GetSubCategoriesByFilterRequest request)
    {
        Command.Name = "sp_get_sub_categories_by_filter";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", request.MainCategoryId);
        Command.AddParameter("category_id", request.CategoryId);
        var genderListTable = TableHelper.ConvertToDataTable(request.ClothingGenderId);
        Command.AddParameter("clothing_gender_ids", genderListTable);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetGendersByFilterAsync(string token)
    {
        Command.Name = "sp_get_genders_by_filter";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetProductInfoAsync(string token, string variationCode)
    {
        Command.Name = "sp_select_product_info";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetProductReviewsAsync(string token, string variationCode, int page, int pageSize)
    {
        Command.Name = "sp_get_product_reviews";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);
        Command.AddParameter("page", page);
        Command.AddParameter("page_size", pageSize);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> AddOrUpdateReviewAsync(string token, string variationCode, int rating, string comment)
    {
        Command.Name = "sp_add_or_update_review";
        Command.AddParameter("token", token);
        Command.AddParameter("product_variation_id", variationCode);
        Command.AddParameter("rating", rating);
        Command.AddParameter("comment", comment);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> ToggleFavoriteAsync(string token, string variationCode)
    {
        Command.Name = "sp_toggle_favorite";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<string?> GetFavoritesAsync(string token, int page, int pageSize)
    {
        Command.Name = "sp_get_favorites";
        Command.AddParameter("token", token);
        Command.AddParameter("page_number", page);
        Command.AddParameter("page_size", pageSize);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetAvailableSizesAsync(string token, string variationCode)
    {
        Command.Name = "sp_select_available_sizes";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCountriesAsync(string token)
    {
        Command.Name = "sp_get_countries";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetLocationsByCountryAsync(string token, string countryId)
    {
        Command.Name = "sp_get_locations_by_country";
        Command.AddParameter("token", token);
        Command.AddParameter("country_id", countryId);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetCountriesAndRegionsAsync(string token)
    {
        Command.Name = "sp_get_all_countries_and_regions";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetUserInfoAsync(string token)
    {
        Command.Name = "sp_select_user_info";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> UpdateUserAsync(string token, UpdateUserRequest request)
    {
        Command.Name = "sp_update_user";
        Command.AddParameter("token", token);
        Command.AddParameter("new_email", request.NewEmail);
        Command.AddParameter("phone_number", request.PhoneNumber);
        Command.AddParameter("new_country_id", request.NewCountryId);
        Command.AddParameter("new_location_id", request.NewLocationId);
        Command.AddParameter("new_city", request.NewCity);
        Command.AddParameter("new_zip_code", request.NewZipCode);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<string?> GetStoredPasswordAsync(string token)
    {
        Command.Name = "sp_get_stored_password";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<int> ChangePasswordAsync(string token, UpdatePasswordRequest request)
    {
        string? storedPassword = await GetStoredPasswordAsync(token); // Достать хэш из базы
        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, storedPassword))
        {
            return 400; // Bad Request: Current password is incorrect
        }

        // Проверка совпадения нового пароля
        if (request.NewPassword != request.ConfirmPassword)
        {
            return 422;
        }

        string hashedNewPassword = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        Command.Name = "sp_change_password";
        Command.AddParameter("token", token);
        Command.AddParameter("new_password", hashedNewPassword);

        Command.ReturnValue = new ReturnValueOption("code", SqlDbType.Int);

        return await base.ExecuteCommandAsync<int>();
    }

    public async Task<bool> AddAddressAsync(string token, AddAddressRequest addressRequest)
    {
        Command.Name = "sp_add_user_addresses";
        Command.AddParameter("token", token);
        Command.AddParameter("first_name", addressRequest.FirstName);
        Command.AddParameter("last_name", addressRequest.LastName);
        Command.AddParameter("street_address", addressRequest.StreetAddress);
        Command.AddParameter("street_address_second", addressRequest.StreetAddressSecond);
        Command.AddParameter("country_id", addressRequest.CountryId);
        Command.AddParameter("location_id", addressRequest.LocationId);
        Command.AddParameter("city", addressRequest.City);
        Command.AddParameter("zip_code", addressRequest.ZipCode);
        Command.AddParameter("phone_number", addressRequest.PhoneNumber);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<string?> GetAddressesAsync(string token)
    {
        Command.Name = "get_user_addresses";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> UpdateAddressAsync(string token, string addressId, UpdateAddressRequest request)
    {
        Command.Name = "sp_update_user_address";
        Command.AddParameter("token", token);
        Command.AddParameter("address_id", addressId);
        Command.AddParameter("@first_name", request.FirstName);
        Command.AddParameter("last_name", request.LastName);
        Command.AddParameter("street_address", request.StreetAddress);
        Command.AddParameter("street_address_second", request.StreetAddressSecond);
        Command.AddParameter("country_id", request.CountryId);
        Command.AddParameter("location_id", request.LocationId);
        Command.AddParameter("city", request.City);
        Command.AddParameter("zip_code", request.ZipCode);
        Command.AddParameter("phone_number", request.PhoneNumber);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteAddressAsync(string token, string addressId)
    {
        Command.Name = "sp_delete_user_address";
        Command.AddParameter("token", token);
        Command.AddParameter("address_id", addressId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<bool> AddBankCardAsync(string token, AddBankCardRequest bankCardRequest)
    {
        Command.Name = "add_user_bank_card";
        Command.AddParameter("token", token);
        Command.AddParameter("card_number", bankCardRequest.CardNumber);
        Command.AddParameter("card_holder_name", bankCardRequest.CardHolderName);
        Command.AddParameter("card_holder_surname", bankCardRequest.CardHolderSurname);
        Command.AddParameter("expiration_date", bankCardRequest.ExpirationDate);
        Command.AddParameter("cvv", bankCardRequest.CVV);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<string?> GetBankCardsAsync(string token)
    {
        Command.Name = "get_user_bank_cards";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> UpdateBankCardAsync(string token, string bankCardId, UpdateBankCardRequest updateBankCardRequest)
    {
        Command.Name = "update_user_bank_card";
        Command.AddParameter("token", token);
        Command.AddParameter("bank_card_id", bankCardId);
        Command.AddParameter("card_number", updateBankCardRequest.CardNumber);
        Command.AddParameter("card_holder_name", updateBankCardRequest.CardHolderName);
        Command.AddParameter("card_holder_surname", updateBankCardRequest.CardHolderSurname);
        Command.AddParameter("expiration_date", updateBankCardRequest.ExpirationDate);
        Command.AddParameter("cvv", updateBankCardRequest.CVV);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<bool> DeleteBankCardAsync(string token, string bankCardId)
    {
        Command.Name = "delete_user_bank_card";
        Command.AddParameter("token", token);
        Command.AddParameter("bank_card_id", bankCardId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<string?> SearchAsync(string token, SearchRequest request)
    {
        Command.Name = "sp_search";
        
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", request.MainCategoryId);
        Command.AddParameter("category_id", request.CategoryId);
        Command.AddParameter("sub_category_id", request.SubCategoryId);
        Command.AddParameter("fabric", request.Fabric);
        Command.AddParameter("keyword", request.Keywords);
        Command.AddParameter("product_name", request.ProductName);

        return await base.ExecuteCommandAsync<string>();
    }
    
    public async Task<bool> AddToCartAsync(string token,string variationCode,string sizeId)
    {
        Command.Name = "add_to_cart";
        Command.AddParameter("token", token);
        Command.AddParameter("variation_code", variationCode);
        Command.AddParameter("size_id", sizeId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<string?> ViewCartAsync(string token)
    {
        Command.Name = "view_cart";
        
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }
    
    public async Task<bool> UpdateCartItemQuantityAsync(string token,string cartItemId,int quantity)
    {
        Command.Name = "update_cart_item_quantity";
        Command.AddParameter("token", token);
        Command.AddParameter("cart_item_id", cartItemId);
        Command.AddParameter("quantity", quantity);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<bool> ToggleIsSelectedAsync(string token,string cartItemId)
    {
        Command.Name = "toggle_is_selected";
        Command.AddParameter("token", token);
        Command.AddParameter("cart_item_id", cartItemId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<decimal> CalculateCartTotalAsync(string token,string promoCodeId)
    {
        Command.Name = "calculate_cart_total";
        
        Command.AddParameter("token", token);
        Command.AddParameter("promo_code_id", promoCodeId);

        Command.ReturnValue = new ReturnValueOption("total_price", SqlDbType.Decimal);

        return await base.ExecuteCommandAsync<decimal>();
    }
    
    public async Task<bool> ValidatePromoCodeAsync(string token,string promoCodeId)
    {
        Command.Name = "validate_promo_code";
        
        Command.AddParameter("token", token);
        Command.AddParameter("promo_code_id", promoCodeId);

        Command.ReturnValue = new ReturnValueOption("is_valid", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<bool> CheckoutAsync(string token,string promoCodeId,string addressId,string bankCardId)
    {
        Command.Name = "checkout";
        Command.AddParameter("token", token);
        Command.AddParameter("promo_code_id", promoCodeId);
        Command.AddParameter("address_id", addressId);
        Command.AddParameter("bank_card_id", bankCardId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<string?> OrdersAsync(string token)
    {
        Command.Name = "sp_view_user_orders";
        
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }
    
    public async Task<bool> DeleteAccountAsync(string token)
    {
        Command.Name = "sp_delete_account";
        Command.AddParameter("token", token);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
}