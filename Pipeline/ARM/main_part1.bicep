@description('Name for the key vault')
param vaults_SQLerver_name string 

@description('Specifies the id of the role(Key Vault Secrets User) and the id of the user to be granted the role')
param roleDefinitionResourceId string 
param principalId string 

@description('Location of the data factory.')
param location string 

@description('Specifies the value of the secret that you want to create.')
@secure()//the scret will be declared in powershell and will not be shown in the logs or deployment outputs
param userpswd string
//param user string

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string 

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 

@description('Data Factory Name')
param dataFactoryName string 

@description('Name for the self hosted inegration runtime')
param integrationRuntimeName string 

module dataFactory 'modules/dataFactory.bicep'={
  name:'dataFactory_demoProject'
  params:{
    dataFactoryName:dataFactoryName
    location:location
    integrationRuntimeName:integrationRuntimeName
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault_demoProject'
  params: {
    vaults_SQLerver_name: vaults_SQLerver_name
    location: location
    roleDefinitionResourceId: roleDefinitionResourceId
    principalId: principalId
    userpswd: userpswd
    dataFactoryName: dataFactoryName // Ensure this matches the parameter names in the module
    }
  dependsOn: [
    dataFactory
  ]
}


module storageAccount 'modules/storageAccount.bicep'={
  name:'storageAccount_demoProject'
  params:{
    blobContainerName:blobContainerName
    location:location
    strgVassilis:strgVassilis
  }
  dependsOn: [
    dataFactory, keyVault         
  ]
}




