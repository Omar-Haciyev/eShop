using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record UserInfoResponse(
    [property: JsonPropertyName("email")] string Email,
    [property: JsonPropertyName("password")]
    string Password,
    [property: JsonPropertyName("phone_number")]
    string PhoneNumber,
    [property: JsonPropertyName("birth_date")]
    DateTime? BirthDate,
    [property: JsonPropertyName("Country/Region")]
    string CountryRegion,
    [property: JsonPropertyName("State")] string State,
    [property: JsonPropertyName("Province")]
    string Province,
    [property: JsonPropertyName("City")] string City,
    [property: JsonPropertyName("Postcode")]
    string Postcode);