namespace eShopEngine.API.DTOs.Requests;

public record UpdateBankCardRequest(
    string CardNumber,
    string CardHolderName,
    string CardHolderSurname,
    string ExpirationDate,
    string CVV) : AddBankCardRequest(CardNumber, CardHolderName, CardHolderSurname, ExpirationDate, CVV);