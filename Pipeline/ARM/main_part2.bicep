//params for Data Factory
@description('Data Factory Name')
param dataFactoryName string 

@description('Name for the key vault')
param vaults_SQLerver_name string 

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 


//params for Databricks
@description('Name of the Databricks workspace.')
param workspaceName string

@description('Tier of the Databricks workspace (e.g., standard or premium).')
@allowed([
  'standard'
  'premium'
])
param tier string = 'premium'

@description('Enable "No Public IP" feature.')
param enableNoPublicIp bool

@description('Tags to be applied to the Databricks workspace.')
param tagValues object

//Modules
module ADFobjects 'modules/ADFobjects.bicep'={
  name:'ADFobjects_demoProject'
  params:{
    dataFactoryName:dataFactoryName
    strgVassilis:strgVassilis
    vaults_SQLerver_name:vaults_SQLerver_name
  }
}

module Databricks 'modules/Databricks.bicep'={
  name:'Databricks_demoProject'
  params:{
    workspaceName: workspaceName
    tier: tier
    enableNoPublicIp: enableNoPublicIp
    tagValues: tagValues
  }
}
