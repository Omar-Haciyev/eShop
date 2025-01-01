using System.Text.RegularExpressions;

namespace eShopEngine.API.Helpers;

public static class EmailValidator
{
    private static readonly Regex EmailRegex = 
        new(@"^[^\s@]+@[^\s@]+\.[^\s@]+$", RegexOptions.Compiled);

    public static bool IsValid(string email) => EmailRegex.IsMatch(email);
}