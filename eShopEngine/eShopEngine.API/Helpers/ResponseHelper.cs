using eShopEngine.API.DTOs.Responses;

namespace eShopEngine.API.Helpers;

public static class ResponseHelper
{
    public static CustomResponseModel<T> Error<T>(int code, string errorMessage)
    {
        return new CustomResponseModel<T>
        {
            Result = new CustomResponseModel<T>.ResultModel
            {
                Status = false,
                Code = code,
                Time = 0,
                Error = true,
                ErrorMsg = errorMessage
            },
            Data = default
        };
    }

    public static CustomResponseModel<T> Success<T>(T data)
    {
        return new CustomResponseModel<T>
        {
            Result = new CustomResponseModel<T>.ResultModel
            {
                Status = true,
                Code = 200,
                Time = 0,
                Error = false,
                ErrorMsg = null
            },
            Data = data
        };
    }
}
