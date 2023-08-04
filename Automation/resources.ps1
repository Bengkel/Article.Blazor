# Create a random number to assure unique names
$RandomNumber = Get-Random -Minimum -100 -Maximum 999

# Required parameters
$tenantId = "4c837126-74c9-4b9b-9b8a-9993fbd5e0e3"
$appRegName = "article-blazor"
$resourceGroup = "article-blazor-"+$RandomNumber+"-rg"
$location = "westeurope"
$storName = "blazorapi"+$RandomNumber+"funcst"
$storSku = "Standard_LRS"
$funcName = $appRegName+"-func"
$funcVersion = "4"
$funcReply = "https://"+$funcName+".azurewebsites.net/.auth/login/aad/callback"

# 1. Create a Resource Group
az group create --location $location --resource-group $resourceGroup

# 2. Create a storage account for the function app
az storage account create --name $storName --resource-group $resourceGroup --location $location --sku $storSku

# 3. Create a azure function app
az functionapp create --resource-group $resourceGroup --consumption-plan-location $location --name $funcName --storage-account $storName --functions-version $funcVersion

# 4. Get the App Registration clientId/appId
$appId=$(az ad app create --display-name $appRegName --required-resource-accesses @app-manifest.json --query appId --output tsv)

# 5. Get the App Registration secret/password
$appPassword = az ad app credential reset --id=$appId --display-name secret --query password --output tsv

# 6. Add indentifiers-uris 
az ad app update --id $appId --identifier-uris api://$appId

# 7. Set Authentication for Azure Function
az webapp auth microsoft update --name $funcName --resource-group $resourceGroup --client-id $appId --client-secret $appPassword --tenant-id $tenantId

Write-Output "tenanId : "+$tenantId
Write-Output "clientId : "+$appId