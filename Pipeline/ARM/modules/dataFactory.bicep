@description('Data Factory Name')
param dataFactoryName string 

@description('Location of the data factory.')
param location string 

@description('Name for the self hosted inegration runtime')
param integrationRuntimeName string 



resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}



resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: dataFactory
  name: integrationRuntimeName
  properties: {
    type: 'SelfHosted'
  }
}

