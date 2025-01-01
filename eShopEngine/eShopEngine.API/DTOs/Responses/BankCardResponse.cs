using System.Text.Json.Serialization;

namespace eShopEngine.API.DTOs.Responses;

public record BankCardResponse(
    [property: JsonPropertyName("bank_card_id")] string BankCardId,
    [property: JsonPropertyName("card_number")] string CardNumber,
    [property: JsonPropertyName("expiration_date")]string ExpirationDate);