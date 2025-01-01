using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ReviewResponse(
    [property: JsonPropertyName("reviewer_name")] string ReviewerName,
    [property: JsonPropertyName("stars")] int Stars,
    [property: JsonPropertyName("review_comment")] string? ReviewComment,
    [property: JsonPropertyName("review_date")] DateTime ReviewDate
);