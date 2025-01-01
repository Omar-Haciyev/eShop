using System.Text.Json;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Enums;
using eShopEngine.API.Repositories.Interfaces;
using Microsoft.AspNetCore.Mvc.Filters;
using WebExtensions.Helpers;

namespace eShopEngine.API.Filters;

public class AuthorizationFilter(Roles role) : Attribute, IAsyncAuthorizationFilter
{
    public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
    {
        var repository = context.HttpContext.RequestServices.GetService<ISecurityRepository>();

        var token = context.HttpContext.Request.Headers["token"];

        if (string.IsNullOrEmpty(token))
        {
            context.Result = Respondent.Error(ErrorMsgEnum.TokenIsNotDefined);
            return;
        }

        var result = await repository.AuthorizationTokenAsync(token);

        var resultModel = JsonSerializer.Deserialize<GenerateTokenResponse>(result);

        if (string.IsNullOrEmpty(resultModel.Token))
        {
            context.Result = Respondent.Error(ErrorMsgEnum.TokenIsNotValid);
            return;
        }

        // if (resultModel.ExpiredDate == null || (resultModel.ExpiredDate - DateTime.UtcNow)?.TotalMinutes <= 0)
        // {
        //     context.Result = Respondent.Error(ErrorMsgEnum.TokenIsNotValid);
        //     return;
        // }

        if (role == Roles.Any)
            return;

        if (role == Roles.AuthorizeUser)
        {
            if (resultModel.Role == Roles.Admin.ToString() || resultModel.Role == Roles.Client.ToString())
            {
                return;
            }
        }

        if (role == Roles.User)
        {
            if (resultModel.Role != Roles.Guest.ToString())
                return;

            context.Result = Respondent.Error(ErrorMsgEnum.AccessDenied);
            return;
        }

        if (resultModel.Role == role.ToString())
            return;

        context.Result = Respondent.Error(ErrorMsgEnum.AccessDenied);
    }
}