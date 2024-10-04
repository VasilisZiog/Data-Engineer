targetScope = 'subscription'

@description('Name of the managed resource group for the Databricks workspace.')
param managedResourceGroupName string='databricks-managed-rg-demo'

@description('Location of the managed resource group.')
param location string='eastus'

resource managedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: managedResourceGroupName
  location: location
}


