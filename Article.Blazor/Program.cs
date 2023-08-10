using Article.Blazor;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// REMARK Add Microsoft.Extensions.Http package

// REMARK Register CustomAuthorizationMessageHandler 
builder.Services.AddScoped<CustomAuthorizationMessageHandler>();

// REMARK Configure httpclient
var apiUrl = builder.Configuration.GetValue<string>("Api:Url"); 

builder.Services.AddHttpClient("ServerAPI", client =>
  client.BaseAddress = new Uri(apiUrl))
        .AddHttpMessageHandler<CustomAuthorizationMessageHandler>();

// REMARK Register the httpclient
builder.Services.AddScoped(sp => sp.GetRequiredService<IHttpClientFactory>()
    .CreateClient("ServerAPI"));

// REPLACE
//builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

builder.Services.AddMicrosoftGraphClient("https://graph.microsoft.com/User.Read");

builder.Services.AddMsalAuthentication(options =>
{
    builder.Configuration.Bind("AzureAd", options.ProviderOptions.Authentication);
    options.ProviderOptions.DefaultAccessTokenScopes.Add("https://graph.microsoft.com/User.Read");
});

await builder.Build().RunAsync();