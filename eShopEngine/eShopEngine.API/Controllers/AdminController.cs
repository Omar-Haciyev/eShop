using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Enums;
using eShopEngine.API.Filters;
using eShopEngine.API.Helpers;
using eShopEngine.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using WebExtensions.Helpers;

namespace eShopEngine.API.Controllers;

[Route("api/admin")]
public class AdminController(IAdminService adminService, IBlobService blobService) : ControllerBase
{
    [HttpPost]
    [Route("add-main-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddMainCategoryAsync([FromHeader] string token, string mainCategoryName)
    {
        var response = await adminService.AddMainCategoryAsync(token, mainCategoryName);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPut]
    [Route("update-main-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateMainCategoryAsync([FromHeader] string token, int mainCategoryId, string name)
    {
        var response = await adminService.UpdateMainCategoryAsync(token, mainCategoryId, name);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-main-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteMainCategoryAsync([FromHeader] string token, int mainCategoryId)
    {
        var response = await adminService.DeleteMainCategoryAsync(token, mainCategoryId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddCategoryAsync([FromHeader] string token, string categoryName)
    {
        var response = await adminService.AddCategoryAsync(token, categoryName);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPut]
    [Route("update-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateCategoryAsync([FromHeader] string token, int categoryId, string name)
    {
        var response = await adminService.UpdateCategoryAsync(token, categoryId, name);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteCategory([FromHeader] string token, int categoryId)
    {
        var response = await adminService.DeleteCategory(token, categoryId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-sub-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddSubCategoryAsync([FromHeader] string token, int categoryId,
        string subCategoryName)
    {
        var response = await adminService.AddSubCategoryAsync(token, categoryId, subCategoryName);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPut]
    [Route("update-sub-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateSubCategoryAsync([FromHeader] string token, int subCategoryId, string name)
    {
        var response = await adminService.UpdateSubCategoryAsync(token, subCategoryId, name);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-sub-category")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteSubCategoryAsync([FromHeader] string token, int subCategoryId)
    {
        var response = await adminService.DeleteSubCategoryAsync(token, subCategoryId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("create-hierarchy")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> CreateHierarchyAsync([FromHeader] string token, int[] mainCategoryIds,
        int[] subCategoryIds)
    {
        var response = await adminService.CreateHierarchyAsync(token, mainCategoryIds, subCategoryIds);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPut]
    [Route("update-hierarchy")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateHierarchyAsync([FromHeader] string token, int hierarchyId,
        int mainCategoryId, int categoryId, int subCategoryId)
    {
        var response =
            await adminService.UpdateHierarchyAsync(token, hierarchyId, mainCategoryId, categoryId, subCategoryId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("delete-hierarchy")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteHierarchyAsync([FromHeader] string token, int hierarchyId)
    {
        var response = await adminService.DeleteHierarchyAsync(token, hierarchyId);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpGet]
    [Route("hierarchy")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<HierarchyResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetHierarchyAsync([FromHeader] string token)
    {
        var response = await adminService.GetHierarchyAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpGet]
    [Route("hierarchy-v2")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<object>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GetHierarchyAsyncV2([FromHeader] string token)
    {
        var response = await adminService.GetHierarchyAsyncV2(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-product")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddProductAsync([FromHeader] string token, AddProductRequest request)
    {
        var response = await adminService.AddProductAsync(token, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-images")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddProductImagesAsync([FromHeader] string token,
        [FromForm] string productVariationId, [FromForm] List<IFormFile> images)
    {
        if (images.Any(image => !image.ContentType.StartsWith("image/")))
            return BadRequest(ResponseHelper.Error<bool>(400, "Only image files are allowed."));

        var response = await adminService.AddProductImagesAsync(token, productVariationId, images);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    
    [HttpDelete]
    [Route("delete-product-image")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> DeleteProductImagesAsync([FromHeader] string token, string productVariationId, string[] imageIdsToDelete)
    {
        if (string.IsNullOrEmpty(productVariationId))
            return BadRequest("Product variation ID cannot be null or empty.");

        if (imageIdsToDelete == null || imageIdsToDelete.Length == 0)
            return BadRequest("No image IDs provided for deletion.");

        var response = await adminService.DeleteProductImagesAsync(token, productVariationId, imageIdsToDelete);

        if (response.Result.Error) // Здесь проверяем флаг Error из результата
        {
            return StatusCode(response.Result.Code, response.Result.ErrorMsg); // Код и сообщение ошибки из результата
        }

        return Ok(response); // Возвращаем успешный результат
    }

    [HttpPut]
    [Route("update-product")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateProductAsync([FromHeader] string token,
        [FromBody] UpdateProductRequest request)
    {
        var response = await adminService.UpdateProductAsync(token, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPatch]
    [Route("update-inventory-quantity")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UpdateInventoryAsync([FromHeader] string token, string productVariationId,
        int quantity)
    {
        var response = await adminService.UpdateInventoryAsync(token, productVariationId, quantity);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("add-product-variations")]
    [AuthorizationFilter(Roles.Admin)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> AddProductVariationsAsync([FromHeader] string token,
        [FromBody] AddProductVariationRequest request)
    {
        var response = await adminService.AddProductVariationsAsync(token, request);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
}