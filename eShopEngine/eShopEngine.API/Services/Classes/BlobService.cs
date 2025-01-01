using System.Security.Cryptography;
using Azure.Storage.Blobs;
using eShopEngine.API.Services.Interfaces;

namespace eShopEngine.API.Services.Classes;

public class BlobService : IBlobService
{
    private readonly BlobServiceClient _blobServiceClient;
    private readonly string _containerName;

    public BlobService(IConfiguration configuration)
    {
        var connectionString = configuration["AzureBlobStorage:ConnectionString"];
        _blobServiceClient = new BlobServiceClient(connectionString);
        _containerName = configuration["AzureBlobStorage:ContainerName"];
    }

    public async Task<string> UploadBlobAsync(IFormFile file)
    {
        var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
        await containerClient.CreateIfNotExistsAsync();
        await containerClient.SetAccessPolicyAsync(Azure.Storage.Blobs.Models.PublicAccessType.Blob);

        await using var stream = file.OpenReadStream();
        using var md5 = MD5.Create();
        var hash = BitConverter.ToString(await md5.ComputeHashAsync(stream)).Replace("-", "").ToLowerInvariant();

        var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
        var fileName = $"{hash}{fileExtension}";
        var blobClient = containerClient.GetBlobClient(fileName);

        if (await blobClient.ExistsAsync())
            return blobClient.Uri.ToString(); 

        var blobHttpHeaders = new Azure.Storage.Blobs.Models.BlobHttpHeaders
        {
            ContentType = file.ContentType
        };

        stream.Position = 0; 
        await blobClient.UploadAsync(stream, new Azure.Storage.Blobs.Models.BlobUploadOptions
        {
            HttpHeaders = blobHttpHeaders
        });

        return blobClient.Uri.ToString();
    }
    
    public async Task<bool> DeleteBlobAsync(string fileUrl)
    {
        // Извлечение имени файла из полного URL
        var fileName = Path.GetFileName(new Uri(fileUrl).AbsolutePath);

        var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
        var blobClient = containerClient.GetBlobClient(fileName);

        if (!await blobClient.ExistsAsync()) 
        {
            Console.WriteLine($"Blob does not exist: {fileName}");
            return false;
        }

        await blobClient.DeleteIfExistsAsync();
        Console.WriteLine($"Blob deleted: {fileName}");
        return true;
    }
}