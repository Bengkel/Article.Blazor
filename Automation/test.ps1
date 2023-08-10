# Set oauth2PermissionScopes for api
$apiClientId = "eae50742-fa5b-4d95-a48a-959e28e47514"

$apiScopeId = [guid]::NewGuid().Guid
$apiScopeJson = @{
    requestedAccessTokenVersion = 2
    oauth2PermissionScopes      = @(
        @{
            adminConsentDescription = "$AppName on $EnvironmentAbbrev"
            adminConsentDisplayName = "$AppName on $EnvironmentAbbrev"
            id                      = "$apiScopeId"
            isEnabled               = $true
            type                    = "User"
            userConsentDescription  = "$AppName on $EnvironmentAbbrev"
            userConsentDisplayName  = "$AppName on $EnvironmentAbbrev"
            value                   = "authenticate"
        }
    )
} | ConvertTo-Json -d 4 -Compress

$apiUpdateBody = $apiScopeJson | ConvertTo-Json -d 4

az ad app update --id $apiClientId --set api=$apiUpdateBody --verbose

