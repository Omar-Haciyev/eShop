using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record HierarchyListResponse(
    [property: JsonPropertyName("hierarchies")]
    List<HierarchyResponse> HierarchyResponse);