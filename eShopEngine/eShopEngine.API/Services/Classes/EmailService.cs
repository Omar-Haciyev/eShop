using System.Net;
using System.Net.Mail;
using eShopEngine.API.Services.Interfaces;

namespace eShopEngine.API.Services.Classes;

public class EmailService : IEmailService
{
    private readonly SmtpClient _smtpClient = new("smtp.gmail.com")
    {
        Port = 587,
        Credentials = new NetworkCredential("haciyevomer62@gmail.com", "fzrshofiupsynzdv"),
        EnableSsl = true

    };

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var mailMessage = new MailMessage("haciyevomer62@gmail.com", toEmail, subject, body);
        await _smtpClient.SendMailAsync(mailMessage);
    }
}

