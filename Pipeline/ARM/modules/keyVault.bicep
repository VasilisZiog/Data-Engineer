@description('Data Factory Name')
param dataFactoryName string 

@description('Location of the data factory.')
param location string

@description('Name for the key vault')
param vaults_SQLerver_name string

@description('Specifies the id of the role(Key Vault Secrets User) and the id of the user to be granted the role')
param roleDefinitionResourceId string
param principalId string 

@description('Specifies the value of the secret that you want to create.')
param userpswd string
//param user string



resource vaults_SQLerver_name_resource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaults_SQLerver_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: 'https://${vaults_SQLerver_name}${environment().suffixes.keyvaultDns}'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vaults_SQLerver_name_resource
  name: guid(vaults_SQLerver_name_resource.id, principalId, roleDefinitionResourceId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: principalId
    principalType: 'User'
  }
}



resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}


resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vaults_SQLerver_name_resource
  name: guid(vaults_SQLerver_name_resource.id,vaults_SQLerver_name_resource.name, roleDefinitionResourceId)
  properties: {
    roleDefinitionId: roleDefinitionResourceId
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}



resource vaults_SQLerver_name_adventureWorks2019userPSWD 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vaults_SQLerver_name_resource
  name: 'adventureWorks2019userPSWD'
  properties: {
    value : userpswd
  }
}







