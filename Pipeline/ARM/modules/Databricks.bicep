@description('Name of the Databricks workspace.')
param workspaceName string

@description('Tier of the Databricks workspace (e.g., standard or premium).')
@allowed([
  'standard'
  'premium'
])
param tier string 

@description('Enable No Public IP for the workspace.')
param enableNoPublicIp bool= true

@description('Tags to be applied to the Databricks workspace.')
param tagValues object

param managedResourceGroupName string='databricks-managed-rg-demo'



resource managedRG 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: managedResourceGroupName
}

// Managed resource group ID using resourceId function
var managedResourceGroupId = resourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)


resource databricksWorkspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: resourceGroup().location
  sku: {
    name: tier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId // Using resourceId function
    parameters: {
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
    }
    defaultCatalog: {
      initialType: 'UnityCatalog'
      initialName: ''
    }
  }
  tags: tagValues
  dependsOn: [
    managedRG
  ]
}
