# Create a random number to assure unique names
$RandomNumber = Get-Random -Minimum -100 -Maximum 999

# Required parameters
$tenantId = "4c837126-74c9-4b9b-9b8a-9993fbd5e0e3" #<your-azure-tenant-id>
$appRegName = "article-blazor" #<your-app-registration-name>
$scopename = "user_impersonation"
$resourceGroup = $appRegName + $RandomNumber + "-rg"
$location = "westeurope"
$storName = "blazorapi" + $RandomNumber + "funcst"
$storSku = "Standard_LRS"
$funcName = $appRegName + $RandomNumber + "-func"
$funcVersion = "4"
$blazorUrl = "https://localhost:7040" #<your-blazor-app-url>

# 1. Create a Resource Group
az group create --location $location --resource-group $resourceGroup

# 2. Create a storage account for the function app
az storage account create  `
    --name $storName  `
    --resource-group $resourceGroup  `
    --location $location  `
    --sku $storSku

# 3. Create a azure function app
az functionapp create  `
    --resource-group $resourceGroup  `
    --consumption-plan-location $location  `
    --name $funcName  `
    --storage-account $storName  `
    --functions-version $funcVersion

# 4. Configure azure function cors
az functionapp cors add  `
    --resource-group $resourceGroup  `
    --name $funcName  `
    --allowed-origins $blazorUrl

# 5. Get the App Registration clientId/appId
$appId=$(az ad app create  `
    --display-name $appRegName  `
    --required-resource-accesses @app-manifest.json  `
    --query appId  `
    --output tsv)

# 6. Get the App Registration secret/password
$appPassword = az ad app credential reset  `
    --id=$appId  `
    --display-name secret  `
    --query password  `
    --output tsv

# 7. Add indentifier uri
az ad app update  `
    --id $appId  `
    --identifier-uris api://$appId

# 8. Set oauth2PermissionScopes for api
$apiScopeId = [guid]::NewGuid().Guid
$apiScopeJson = @{
    requestedAccessTokenVersion = 2
    oauth2PermissionScopes      = @(
        @{
            adminConsentDescription = "Allow the application to access the API on behalf of the signed-in user."
            adminConsentDisplayName = "$appRegName"
            id                      = "$apiScopeId"
            isEnabled               = $true
            type                    = "User"
            userConsentDescription  = "$appRegName"
            userConsentDisplayName  = "Allow the application to access the API on your behalf."
            value                   = $scopename
        }
    )
} | ConvertTo-Json -d 4 -Compress

$apiUpdateBody = $apiScopeJson | ConvertTo-Json -d 4

az ad app update  `
    --id $appId  `
    --set api=$apiUpdateBody  `
    --verbose

# 9. Set Authentication for Azure Function
az webapp auth microsoft update  `
    --name $funcName  `
    --resource-group $resourceGroup  `
    --client-id $appId  `
    --client-secret $appPassword  `
    --tenant-id $tenantId --yes

#10. Write the variables for your appsettings.json
Write-Output "<your-function-app-url>=https://$funcName.azurewebsites.net/"
Write-Output "<your-function-app-api-scope>=api://$appId/$scopename"