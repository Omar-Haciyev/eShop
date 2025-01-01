using System.Data;
using eShopEngine.API.Repositories.Classes;
using eShopEngine.API.Repositories.Interfaces;
using eShopEngine.API.Services.Classes;
using eShopEngine.API.Services.Interfaces;
using WebExtensions.Helpers;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration["ConnectionStrings:eCommerceDb"];

builder.Services.AddControllers();
builder.Services.AddCors(options =>
{
    options.AddPolicy("myCors", p => { p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader(); });
});

builder.Services.AddScoped<ISecurityRepository>(provider => 
    new SecurityRepository(connectionString!)
    {
        Command = new Command("eCommerceDb", "dbo", CommandType.StoredProcedure)
    });

builder.Services.AddScoped<IUserRepository>(provider => 
    new UserRepository(connectionString!)
    {
        Command = new Command("eCommerceDb", "dbo", CommandType.StoredProcedure)
    });

builder.Services.AddScoped<IAdminRepository>(provider => 
    new AdminRepository(connectionString!)
    {
        Command = new Command("eCommerceDb", "dbo", CommandType.StoredProcedure)
    });

builder.Services.AddTransient<IEmailService, EmailService>();
builder.Services.AddScoped<ISecurityService, SecurityService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IBlobService, BlobService>();


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("myCors");
app.MapControllers();
app.Run();