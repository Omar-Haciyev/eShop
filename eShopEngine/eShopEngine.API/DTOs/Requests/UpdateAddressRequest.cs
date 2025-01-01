namespace eShopEngine.API.DTOs.Requests;

public record UpdateAddressRequest(
    string FirstName,
    string LastName,
    string StreetAddress,
    string StreetAddressSecond,
    string CountryId,
    string LocationId,
    string City,
    string ZipCode,
    string PhoneNumber);