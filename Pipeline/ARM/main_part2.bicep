//params for Data Factory
@description('Data Factory Name')
param dataFactoryName string 

@description('Name for the key vault')
param vaults_SQLerver_name string 

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 




//Modules
module ADFobjects 'modules/ADFobjects.bicep'={
  name:'ADFobjects_demoProject'
  params:{
    dataFactoryName:dataFactoryName
    strgVassilis:strgVassilis
    vaults_SQLerver_name:vaults_SQLerver_name
  }
}



