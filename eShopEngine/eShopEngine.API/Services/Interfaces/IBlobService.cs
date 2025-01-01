namespace eShopEngine.API.Services.Interfaces;

public interface IBlobService
{
    Task<string> UploadBlobAsync(IFormFile file);
    Task<bool> DeleteBlobAsync(string fileName);
}