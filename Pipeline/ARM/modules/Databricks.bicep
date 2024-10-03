@description('Name of the Databricks workspace.')
param workspaceName string

@description('Tier of the Databricks workspace (e.g., standard or premium).')
@allowed([
  'standard'
  'premium'
])
param tier string 

@description('Enable "No Public IP" feature.')
param enableNoPublicIp bool

@description('Tags to be applied to the Databricks workspace.')
param tagValues object

// Automatically generate the managed resource group name if not specified
var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

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
}
