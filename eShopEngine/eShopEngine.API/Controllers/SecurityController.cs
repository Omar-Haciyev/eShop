using eShopEngine.API.DTOs.Requests;
using eShopEngine.API.DTOs.Responses;
using eShopEngine.API.Enums;
using eShopEngine.API.Filters;
using eShopEngine.API.Helpers;
using eShopEngine.API.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using WebExtensions.Helpers;

namespace eShopEngine.API.Controllers;

[Route("api/security")]
public class SecurityController(ISecurityService securityService) : ControllerBase
{
    [HttpPost]
    [Route("token")]
    [ProducesResponseType(typeof(ResponseModel<GenerateTokenResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> GenerateToken([FromHeader] string key)
    {
        var response = await securityService.GenerateTokenAsync(key);

        if (response.Result.Code == 400 || response.Result.Code == 500)
            return StatusCode(response.Result.Code, response);

        return Ok(response);
    }

    [HttpGet]
    [Route("users/exists")]
    [AuthorizationFilter(Roles.Any)]
    [ProducesResponseType(typeof(ResponseModel<object>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> UserExists([FromHeader] string token, [FromQuery] string email)
    {
        if (!EmailValidator.IsValid(email))
            return Respondent.Error(400, "Invalid email format.");

        var response = await securityService.UserExistsAsync(token, email);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("signup")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<object>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> SignUp([FromHeader] string token, [FromBody] SignUpRequest request)
    {
        // if (!ModelState.IsValid)
        // {
        //     var errorResponse = ResponseHelper.Error<string>(400, "Invalid data");
        //     return BadRequest(errorResponse);
        // }

        if (!ModelState.IsValid)
            return BadRequest(Respondent.Error(ModelState));

        var response = await securityService.SignUpAsync(token, request);

        if (response.Result.Code == 400 || response.Result.Code == 500)
            return StatusCode(response.Result.Code, response);

        return Ok(response);
    }

    [HttpPost]
    [Route("insert-choice")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<ChoiceResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> InsertChoiceUser([FromHeader] string token, [FromBody] ChoiceRequest request)
    {
        if (!ModelState.IsValid)
            return Respondent.Error(ModelState);

        var response = await securityService.InsertChoiceUserAsync(token, request);

        return response.Result.Code switch
        {
            403 => StatusCode(403, response),
            410 => StatusCode(410, response),
            400 => BadRequest(response),
            _ => Ok(response)
        };
    }

    [HttpPut]
    [Route("resend-otp")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<ResendOtpResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ResendOtpCode([FromHeader] string token)
    {
        var response = await securityService.ResendOtpCodeAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }

    [HttpPost]
    [Route("confirm-otp")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<ConfirmOtpResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ConfirmOtp([FromHeader] string token, [FromBody] ConfirmOtpRequest request)
    {
        if (!ModelState.IsValid)
            return Respondent.Error(ModelState);

        var response = await securityService.ConfirmOtpAsync(token, request);

        return response.Result.Code switch
        {
            200 => Ok(response),
            401 => Unauthorized(response),
            404 => NotFound(response),
            410 => StatusCode(410, response),
            _ => StatusCode(500, response)
        };
    }
    
    [HttpPost]
    [Route("sign-in")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<SignInResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> SignIn([FromHeader]string token,[FromBody] SignInRequest request)
    {
        var response = await securityService.SignInAsync(token,request);

        return response.Result.Code switch
        {
            200 => Ok(response),
            401 => Unauthorized(response),
            403 => Forbid(), 
            404 => NotFound(response), 
            410 => StatusCode(410, response),
            429 => StatusCode(429, response),
            _ => StatusCode(500, response) 
        };
    }
    
    [HttpPost]
    [Route("refresh-token")]
    //добавить проверку токена(AuthorizationFilter),решить проблему с передачей token
    public async Task<IActionResult> RefreshToken([FromHeader]string token )
    {
        var response = await securityService.RefreshTokenAsync(token);
        
        if (response == null)
        {
            return Unauthorized(new { status = 401, message = "Invalid or expired refresh token." });
        }
        
        return Ok(response);
    }
    
    [HttpPost]
    [Route("forgot-password")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<ForgotPasswordResponse>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> ForgotPassword([FromHeader] string token, [FromBody] ForgotPasswordRequest request)
    {
        var response = await securityService.ForgotPasswordAsync(token, request);

        return response.Result.Code switch
        {
            200 => Ok(response),
            401 => Unauthorized(response),
            403 => StatusCode(403, ResponseHelper.Error<string>(403, "Access denied.")), 
            404 => NotFound(response),
            429 => StatusCode(429, response),
            _ => StatusCode(500, response)
        };
    }
    
    [HttpPost]
    [Route("forgot-password/confirm-otp")]
    [AuthorizationFilter(Roles.Guest)]
    [ProducesResponseType(typeof(ResponseModel<ForgotPasswordConfirmResponse>), 200)]
    public async Task<IActionResult> ConfirmOtp([FromHeader] string token, [FromBody] ForgotPasswordConfirmRequest request)
    {
        var response = await securityService.ForgotPasswordConfirmOtpAsync(token, request);

        if (!response.Result.Status)
        {
            return BadRequest(response);
        }

        return Ok(response);
    }

    [HttpPost]
    [Route("logout")]
    [AuthorizationFilter(Roles.AuthorizeUser)]
    [ProducesResponseType(typeof(ResponseModel<bool>), 200)]
    [Produces("application/json")]
    public async Task<IActionResult> LogoutAsync([FromHeader] string token)
    {
        var response = await securityService.LogoutAsync(token);

        if (response.Result.Code == 400)
            return BadRequest(response);

        return Ok(response);
    }
}
