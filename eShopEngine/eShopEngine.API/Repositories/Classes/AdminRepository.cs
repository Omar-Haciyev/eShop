using System.Data;
using System.Data.SqlClient;
using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.Helpers;
using eShopEngine.API.Repositories.Interfaces;
using WebExtensions.Helpers;

namespace eShopEngine.API.Repositories.Classes;

public class AdminRepository(string connectionString) : RepositoryHelper(connectionString), IAdminRepository
{
    public async Task<bool> AddMainCategoryAsync(string token, string mainCategoryName)
    {
        Command.Name = "sp_add_main_category";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_name", mainCategoryName);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> UpdateMainCategoryAsync(string token, int mainCategoryId, string name)
    {
        Command.Name = "sp_update_main_category";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", mainCategoryId);
        Command.AddParameter("name", name);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteMainCategoryAsync(string token, int mainCategoryId)
    {
        Command.Name = "sp_delete_main_category";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", mainCategoryId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> AddCategoryAsync(string token, string categoryName)
    {
        Command.Name = "sp_add_category";
        Command.AddParameter("token", token);
        Command.AddParameter("category_name", categoryName);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> UpdateCategoryAsync(string token, int categoryId, string name)
    {
        Command.Name = "sp_update_category";
        Command.AddParameter("token", token);
        Command.AddParameter("category_id", categoryId);
        Command.AddParameter("name", name);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteCategory(string token, int categoryId)
    {
        Command.Name = "sp_delete_category";
        Command.AddParameter("token", token);
        Command.AddParameter("category_id", categoryId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> AddSubCategoryAsync(string token, int categoryId, string subCategoryName)
    {
        Command.Name = "sp_add_sub_category";
        Command.AddParameter("token", token);
        Command.AddParameter("category_id", categoryId);
        Command.AddParameter("sub_category_name", subCategoryName);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> UpdateSubCategoryAsync(string token, int subCategoryId, string name)
    {
        Command.Name = "sp_update_sub_category";
        Command.AddParameter("token", token);
        Command.AddParameter("sub_category_id", subCategoryId);
        Command.AddParameter("name", name);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteSubCategoryAsync(string token, int subCategoryId)
    {
        Command.Name = "sp_delete_sub_category";
        Command.AddParameter("token", token);
        Command.AddParameter("sub_category_id", subCategoryId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> CreateHierarchyAsync(string token, int[] mainCategoryIds, int[] subCategoryIds)
    {
        Command.Name = "sp_create_category_hierarchy";
        Command.AddParameter("token", token);

        var mainCategoryListTable = TableHelper.ConvertToDataTable(mainCategoryIds);
        Command.AddParameter("main_category_id_list", mainCategoryListTable);

        var subCategoryListTable = TableHelper.ConvertToDataTable(subCategoryIds);
        Command.AddParameter("sub_category_id_list", subCategoryListTable);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> UpdateHierarchyAsync(string token, int hierarchyId, int mainCategoryId, int categoryId,
        int subCategoryId)
    {
        Command.Name = "sp_update_hierarchy";
        Command.AddParameter("token", token);
        Command.AddParameter("hierarchy_id", hierarchyId);
        Command.AddParameter("main_category_id", mainCategoryId);
        Command.AddParameter("category_id", categoryId);
        Command.AddParameter("sub_category_id", subCategoryId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteHierarchyAsync(string token, int hierarchyId)
    {
        Command.Name = "sp_delete_hierarchy";
        Command.AddParameter("token", token);
        Command.AddParameter("hierarchy_id", hierarchyId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<string?> GetHierarchyAsync(string token)
    {
        Command.Name = "sp_get_all_hierarchies";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<string?> GetHierarchyAsyncV2(string token)
    {
        Command.Name = "sp_get_all_category_hierarchies_2";
        Command.AddParameter("token", token);

        return await base.ExecuteCommandAsync<string>();
    }

    public async Task<bool> AddProductAsync(string token, AddProductRequest request)
    {
        Command.Name = "sp_add_product";
        Command.AddParameter("token", token);
        Command.AddParameter("main_category_id", request.MainCategoryId);
        Command.AddParameter("sub_category_id", request.SubCategoryId);
        Command.AddParameter("product_name", request.ProductName);
        Command.AddParameter("gender_id", request.GenderId);
        Command.AddParameter("make", request.Make);
        Command.AddParameter("fabric", request.Fabric);
        Command.AddParameter("description", request.Description);
        Command.AddParameter("color_code", request.ColorCode);
        Command.AddParameter("price", request.Price);
        Command.AddParameter("quantity", request.Quantity);

        var sizesTable = TableHelper.ConvertToDataTable(request.SizeList);
        Command.AddParameter("sizes", sizesTable);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> AddProductImagesAsync(string token, string productVariationId, string[] imageUrls)
    {
        Command.Name = "sp_add_product_images";
        Command.AddParameter("token", token);
        Command.AddParameter("product_variation_id", productVariationId);

        var imageUrlListTable = TableHelper.ConvertToDataTable(imageUrls);
        Command.AddParameter("@image_urls", imageUrlListTable);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> DeleteProductImagesAsync(string token, string productVariationId,string []imageIdsToDelete)
    {
        Command.Name = "sp_delete_product_images";
        Command.AddParameter("token", token);
        Command.AddParameter("product_variation_id", productVariationId);

        var imageIdsListTable = TableHelper.ConvertToDataTable(imageIdsToDelete);
        Command.AddParameter("@image_to_delete_ids", imageIdsListTable);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
    
    public async Task<List<string>> GetImageUrlsAsync(string productVariationId, string[] imageIdsToGet)
    {
        await using var connection = new SqlConnection("Server=_THEHACIYEV;Database=eCommerceDb;Integrated Security=SSPI;Encrypt=False;");
        await using var command = new SqlCommand("sp_get_image_urls", connection);
        command.CommandType = CommandType.StoredProcedure;

        // Добавляем параметры для hранимой процедуры
        command.Parameters.Add(new SqlParameter("@product_variation_id", productVariationId));

        // Создаем DataTable для передачи в параметр типа image_id_list
        var imageIdsTable = new DataTable();
        imageIdsTable.Columns.Add("image_id", typeof(string));

        foreach (var imageId in imageIdsToGet)
        {
            imageIdsTable.Rows.Add(imageId);
        }

        // Добавляем параметр типа image_id_list
        var imageIdsParam = new SqlParameter("@image_ids", SqlDbType.Structured)
        {
            TypeName = "dbo.image_id_list",
            Value = imageIdsTable
        };
        command.Parameters.Add(imageIdsParam);

        // Открываем соединение и выполняем команду
        await connection.OpenAsync();
        var reader = await command.ExecuteReaderAsync();

        // Считываем данные
        var imageUrls = new List<string>();
        while (await reader.ReadAsync())
        {
            imageUrls.Add(reader.GetString(0)); // Считываем URL изображения
        }

        return imageUrls;
    }
    
    public async Task<bool> UpdateProductAsync(string token, UpdateProductRequest request)
    {
        Command.Name = "sp_update_product";
        Command.AddParameter("token", token);
        Command.AddParameter("product_id", request.ProductId);
        Command.AddParameter("main_category_id", request.MainCategoryId);
        Command.AddParameter("sub_category_id", request.SubCategoryId);
        Command.AddParameter("product_name", request.ProductName);
        Command.AddParameter("gender_id", request.GenderId);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> UpdateInventoryAsync(string token, string productVariationId, int quantity)
    {
        Command.Name = "sp_update_inventory_quantity";
        Command.AddParameter("token", token);
        Command.AddParameter("product_variation_id", productVariationId);
        Command.AddParameter("new_quantity", quantity);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }

    public async Task<bool> AddProductVariationsAsync(string token, AddProductVariationRequest request)
    {
        Command.Name = "sp_add_product_variations";
        Command.AddParameter("token", token);
        Command.AddParameter("product_id", request.ProductId);
        Command.AddParameter("make", request.Make);
        Command.AddParameter("fabric", request.Fabric);
        Command.AddParameter("description", request.Description);
        Command.AddParameter("color_id", request.ColorId);
        Command.AddParameter("price", request.Price);
        Command.AddParameter("quantity", request.Quantity);

        var sizesTable = TableHelper.ConvertToDataTable(request.Sizes);
        Command.AddParameter("sizes", sizesTable);

        Command.ReturnValue = new ReturnValueOption("sql_result", SqlDbType.Bit);

        return await base.ExecuteCommandAsync<bool>();
    }
}