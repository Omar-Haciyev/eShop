using System.ComponentModel.DataAnnotations;

namespace eShopEngine.API.DTOs.Requests;

public record ChoiceRequest(
    [RegularExpression("^(1|2)$", ErrorMessage = "Choice must be either 1 or 2.")]
    int Choice
);