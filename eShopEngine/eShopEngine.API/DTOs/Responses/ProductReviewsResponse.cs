using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record ProductReviewsResponse(
    [property: JsonPropertyName("total_reviews")] int TotalReviews,
    [property: JsonPropertyName("reviews")] List<ReviewResponse> Reviews
);