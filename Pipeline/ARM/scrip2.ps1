# Helper function to check the last command's exit status and exit if it failed
function Check-LastCommand {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error encountered. Exiting script."
        exit $LASTEXITCODE
    }
}

$resourceGroupName = "vassilisziog"
$location = "eastus"

# Deploy the second part of the main template
az deployment group create --resource-group $resourceGroupName --template-file main_part1.bicep --parameters main_part1.bicepparam 
Check-LastCommand
