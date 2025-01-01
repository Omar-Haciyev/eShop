using System.Text.Json.Serialization;
using Newtonsoft.Json;

namespace eShopEngine.API.DTOs.Responses;

public class MainCategoryResponse
{
    [JsonPropertyName("id")] public int Id { get; set; }

    [JsonPropertyName("name")] public string? Name { get; set; }
}