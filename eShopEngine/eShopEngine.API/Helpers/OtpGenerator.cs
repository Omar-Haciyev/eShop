namespace eShopEngine.API.Helpers;

public static class OtpGenerator
{
    public static string GenerateOtpCode()
    {
        Random random = new Random();
        return random.Next(100000, 999999).ToString();
    }
}