param (
    [parameter(Mandatory = $true)] [String] $databricksWorkspaceResourceId,
    [parameter(Mandatory = $true)] [String] $databricksWorkspaceUrl,
    [parameter(Mandatory = $false)] [int] $tokenLifeTimeSeconds = 300
)

# Azure Databricks Service Principal Application ID
$azureDatabricksPrincipalId = '2ff814a6-3304-4ab8-85cb-cd0e6f879c1d'

# Get Azure Databricks access token
$azAccountToken = az account get-access-token --resource $azureDatabricksPrincipalId | ConvertFrom-Json
$accessToken = $azAccountToken.accessToken

# Get management token
$managementToken = (az account get-access-token --resource https://management.core.windows.net/ | ConvertFrom-Json).accessToken

# Headers
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "X-Databricks-Azure-SP-Management-Token" = $managementToken
    "X-Databricks-Azure-Workspace-Resource-Id" = $databricksWorkspaceResourceId
}

# Body JSON for the request
$json = @{
    lifetime_seconds = $tokenLifeTimeSeconds
}

# Making the request to create a token
$req = Invoke-WebRequest -Uri "https://$databricksWorkspaceUrl/api/2.0/token/create" -Method POST -Headers $headers -Body ($json | ConvertTo-Json) -ContentType "application/json"

# Extract the bearer token from the response
$bearerToken = ($req.Content | ConvertFrom-Json).token_value

return $bearerToken
