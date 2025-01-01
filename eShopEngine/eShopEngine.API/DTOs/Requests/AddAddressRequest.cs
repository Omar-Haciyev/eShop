namespace eShopEngine.API.DTOs.Requests;

public record AddAddressRequest(
    string FirstName,
    string LastName,
    string StreetAddress,
    string StreetAddressSecond,
    string CountryId,
    string LocationId,
    string City,
    string ZipCode,
    string PhoneNumber);