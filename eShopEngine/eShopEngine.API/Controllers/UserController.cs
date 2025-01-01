using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Enums;
using eShopEngine.API.Filters;
using eShopEngine.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using WebExtensions.Helpers;

namespace eShopEngine.API.Controllers;

[Route("api/user")]
public class UserController(IUserService userService) : ControllerBase
{
    [HttpGet]
    [Route("main-categories")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<MainCategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetMainCategories([FromHeader] string token)
    {
        var response = await userService.GetMainCategoriesAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("main-category-by-id")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<MainCategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetMainCategoryByIdAsync([FromHeader] string token, int mainCategoryId)
    {
        var response = await userService.GetMainCategoryByIdAsync(token, mainCategoryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("categories")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<CategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCategories([FromHeader] string token)
    {
        var response = await userService.GetCategoriesAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("category-by-id")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<CategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCategoryByIdAsync([FromHeader] string token, int categoryId)
    {
        var response = await userService.GetCategoryByIdAsync(token, categoryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("sub-categories")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<SubCategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetSubCategories([FromHeader] string token)
    {
        var response = await userService.GetSubCategoriesAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("sub-category-by-id")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<SubCategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetSubCategoryByIdAsync([FromHeader] string token, int subCategoryId)
    {
        var response = await userService.GetSubCategoryByIdAsync(token, subCategoryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("categories-by-main-category-id")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<CategoryByMainCategoryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCategoriesByMainCategoryIdAsync([FromHeader] string token, int mainCategoryId)
    {
        var response = await userService.GetCategoriesByMainCategoryIdAsync(token, mainCategoryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("categories-and-sub-categories-by-main-category-id")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<MainCategoryResponseV2>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCategoriesAndSubCategoriesByMainCategoryIdAsync([FromHeader] string token,
        int mainCategoryId)
    {
        var response = await userService.GetCategoriesAndSubCategoriesByMainCategoryIdAsync(token, mainCategoryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("products")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<ProductResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetProductsAsync([FromHeader] string token, GetProductRequest request)
    {
        var response = await userService.GetProductsAsync(token, request);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("product-preview")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<ProductPreviewResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetProductPreviewAsync([FromHeader] string token, string variationCode)
    {
        var response = await userService.GetProductPreviewAsync(token, variationCode);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("sub-categories-filter")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<SubCategoryResponseWrapper>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetSubCategoriesByFilterAsync([FromHeader] string token,
        [FromQuery] GetSubCategoriesByFilterRequest request)
    {
        var response = await userService.GetSubCategoriesByFilterAsync(token, request);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("genders-filter")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<GenderFilterResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetGendersByFilterAsync([FromHeader] string token)
    {
        var response = await userService.GetGendersByFilterAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("product-info")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<ProductResponseV2>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetProductInfoAsync([FromHeader] string token, string variationCode)
    {
        var response = await userService.GetProductInfoAsync(token, variationCode);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("product-reviews")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<ProductResponseV2>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetProductReviewsAsync([FromHeader] string token, string variationCode,
        int page = 1, int pageSize = 10)
    {
        var response = await userService.GetProductReviewsAsync(token, variationCode, page, pageSize);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpPost]
    [Route("add-or-update-review")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddOrUpdateReviewAsync([FromHeader] string token, string variationCode, int rating,
        string comment)
    {
        var response = await userService.AddOrUpdateReviewAsync(token, variationCode, rating, comment);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("toggle-favorite")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ToggleFavoriteAsync([FromHeader] string token, string variationCode)
    {
        var response = await userService.ToggleFavoriteAsync(token, variationCode);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpGet]
    [Route("favorites")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<object>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetFavorites([FromHeader] string token, int page = 1, int pageSize = 10)
    {
        var response = await userService.GetFavoritesAsync(token, page, pageSize);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("sizes")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<SizesResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetAvailableSizesAsync([FromHeader] string token, string variationCode)
    {
        var response = await userService.GetAvailableSizesAsync(token, variationCode);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("countries")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<CountryResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCountriesAsync([FromHeader] string token)
    {
        var response = await userService.GetCountriesAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("locations")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<LocationResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetLocationsByCountryAsync([FromHeader] string token, string countryId)
    {
        var response = await userService.GetLocationsByCountryAsync(token, countryId);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("countries_and_regions")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<CountryWithRegionsDto>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCountriesAndRegionsAsync([FromHeader] string token)
    {
        var response = await userService.GetCountriesAndRegionsAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpGet]
    [Route("info")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<UserInfoResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetUserInfoAsync([FromHeader] string token)
    {
        var response = await userService.GetUserInfoAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpPost]
    [Route("update")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateUserAsync([FromHeader] string token, [FromBody] UpdateUserRequest request)
    {
        var response = await userService.UpdateUserAsync(token, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("change-password")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(CustomResponseModel<bool>), StatusCodes.Status200OK)]
    [Produces("application/json")]
    public async Task<IActionResult> ChangePasswordAsync([FromHeader] string token,
        [FromBody] UpdatePasswordRequest request)
    {
        var response = await userService.ChangePasswordAsync(token, request);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpPost]
    [Route("add-address")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddAddressAsync([FromHeader] string token,
        [FromBody] AddAddressRequest addressRequest)
    {
        var response = await userService.AddAddressAsync(token, addressRequest);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpGet]
    [Route("addresses")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<UserInfoResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetAddressesAsync([FromHeader] string token)
    {
        var response = await userService.GetAddressesAsync(token);

        return !response.Result.Status ? StatusCode(response.Result.Code, response) : Ok(response);
    }

    [HttpPost]
    [Route("update-address")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateAddressAsync([FromHeader] string token, [FromQuery] string addressId,
        [FromBody] UpdateAddressRequest request)
    {
        var response = await userService.UpdateAddressAsync(token, addressId, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-address")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteAddressAsync([FromHeader] string token, [FromQuery] string addressId)
    {
        var response = await userService.DeleteAddressAsync(token, addressId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-bank-card")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddBankCardAsync([FromHeader] string token,
        [FromBody] AddBankCardRequest bankCardRequest)
    {
        var response = await userService.AddBankCardAsync(token, bankCardRequest);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpGet]
    [Route("bank-card")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<BankCardResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetBankCardsAsync([FromHeader] string token)
    {
        var response = await userService.GetBankCardsAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPut]
    [Route("update-bank-card")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateBankCardAsync([FromHeader] string token, [FromQuery] string bankCardId,
        [FromBody] UpdateBankCardRequest bankCardRequest)
    {
        var response = await userService.UpdateBankCardAsync(token, bankCardId, bankCardRequest);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-bank-card")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateBankCardAsync([FromHeader] string token, [FromQuery] string bankCardId)
    {
        var response = await userService.DeleteBankCardAsync(token, bankCardId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("search")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<ProductResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> SearchAsync([FromHeader] string token, [FromBody] SearchRequest request)
    {
        var response = await userService.SearchAsync(token, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-to-cart")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddToCartAsync([FromHeader] string token, [FromQuery] string variationCode,
        [FromQuery] string sizeId)
    {
        var response = await userService.AddToCartAsync(token, variationCode, sizeId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpGet]
    [Route("cart")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<ProductResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetCartAsync([FromHeader] string token)
    {
        var response = await userService.ViewCartAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpPost]
    [Route("update-cart-item-quantity")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateCartItemQuantityAsync([FromHeader] string token, [FromQuery] string cartItemId,
        [FromQuery] int quantity)
    {
        var response = await userService.UpdateCartItemQuantityAsync(token, cartItemId, quantity);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpPatch]
    [Route("toggle-is-selected")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ToggleIsSelectedAsync([FromHeader] string token, [FromQuery] string cartItemId)
    {
        var response = await userService.ToggleIsSelectedAsync(token, cartItemId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpGet]
    [Route("total-price")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> CalculateCartTotalAsync([FromHeader] string token, [FromQuery] string promoCodeId)
    {
        var response = await userService.CalculateCartTotalAsync(token, promoCodeId);

        return Ok(response);
    }
    
    [HttpGet]
    [Route("validate-promo-code")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ValidatePromoCodeAsync([FromHeader] string token, [FromQuery] string promoCodeId)
    {
        var response = await userService.ValidatePromoCodeAsync(token, promoCodeId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpPost]
    [Route("checkout")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> CheckoutAsync([FromHeader] string token, [FromQuery] string promoCodeId,
        [FromQuery] string addressId,[FromQuery]string bankCardId)
    {
        var response = await userService.CheckoutAsync(token, promoCodeId, addressId, bankCardId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpGet]
    [Route("orders")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<object>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> OrdersAsync([FromHeader] string token)
    {
        var response = await userService.OrdersAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
    
    [HttpPatch]
    [Route("delete-account")]
    [AuthorizationFilter(Roles.User)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteAccountAsync([FromHeader] string token)
    {
        var response = await userService.DeleteAccountAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
}