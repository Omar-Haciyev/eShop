namespace eShopEngine.API.DTOs.Requests;

public record AddBankCardRequest(
    string CardNumber,
    string CardHolderName,
    string CardHolderSurname,
    string ExpirationDate,
    string CVV);