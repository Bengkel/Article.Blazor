using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;

public class CustomAuthorizationMessageHandler : AuthorizationMessageHandler
{
    public CustomAuthorizationMessageHandler(IAccessTokenProvider provider,
        IConfiguration configuration,
        NavigationManager navigationManager)
        : base(provider, navigationManager)
    {
        var apiUrl = configuration.GetValue<string>("Api:Url");
        var scopeName = configuration.GetValue<string>("Api:ScopeName");

        ConfigureHandler(
            authorizedUrls: new[] { apiUrl },
            scopes: new[] { scopeName } );
    }
}
