# Helper function to check the last command's exit status and exit if it failed
function Check-LastCommand {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error encountered. Exiting script."
        exit $LASTEXITCODE
    }
}


$resourceGroupName = "vassilisziog"
$location = "eastus"

# Check if the resource group exists
$rgExists = az group exists --name $resourceGroupName
Check-LastCommand

# If the resource group exists, delete it
if ($rgExists -eq "true") {
    az group delete --name $resourceGroupName --yes
    Check-LastCommand
    Start-Sleep -Seconds 60  # Wait for 60 seconds to ensure the deletion has propagated
} else {
    Write-Host "Resource group '$resourceGroupName' does not exist. Skipping deletion."
}

# Create a new resource group
az group create --name $resourceGroupName --location $location
Check-LastCommand
Start-Sleep -Seconds 30  # Wait for 30 seconds

# Deploy the Key Vault template
az deployment group create --resource-group $resourceGroupName --template-file main_part1.bicep --parameters main_part1.bicepparam 
Check-LastCommand
Start-Sleep -Seconds 60  # Wait for 60 seconds

# Register the Integration Runtime using the PowerShell script
.\RegisterIntegrationRuntime2.ps1
Check-LastCommand
Start-Sleep -Seconds 60  # Wait for 60 seconds

# Deploy the second part of the main template
az deployment group create --resource-group $resourceGroupName --template-file main_part2.bicep --parameters main_part2.bicepparam 
Check-LastCommand
