@description('Data Factory Name')
param dataFactoryName string

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 

@description('Name for the key vault')
param vaults_SQLerver_name string 



resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name:strgVassilis
}



resource keyVaultLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'AzureKeyVault1'
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: 'https://${vaults_SQLerver_name}${environment().suffixes.keyvaultDns}'
    }
  }
}



resource sqlServerLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'SqlServer2'
  properties: {
    annotations: []
    type: 'SqlServer'
    typeProperties: {
      server: 'localhost'
      database: 'AdventureWorks2019'
      encrypt: 'mandatory'
      trustServerCertificate: true
      authenticationType: 'SQL'
      userName: 'user1'
      password: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault1'
          type: 'LinkedServiceReference'
        }
        secretName: 'adventureWorks2019userPSWD'
      }
    }
    connectVia: {
      referenceName: 'itegrationRuntime1'
      type: 'IntegrationRuntimeReference'
    }
  }
}



resource linkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'AzureDatalakeGen21'
  parent: dataFactory
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: 'https://${strgVassilis}.dfs.${environment().suffixes.storage}'
      accountKey: storageAccount.listKeys().keys[0].value
    }
  }
}



resource sqlDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'AllTables'
  properties: {
    linkedServiceName: {
      referenceName: 'SqlServer2'
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'SqlServerTable'
    schema: []
  }
  dependsOn: [
    sqlServerLinkedService
  ]
}



resource parquetDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'parquetTables'
  properties: {
    linkedServiceName: {
      referenceName: 'AzureDatalakeGen21'
      type: 'LinkedServiceReference'
    }
    parameters: {
      tableName: {
        type: 'string'
      }
      schemaName: {
        type: 'string'
      }
    }
    annotations: []
    type: 'Parquet'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@{concat(dataset().tableName,\'.parquet\')}'
          type: 'Expression'
        }
        folderPath: {
          value: '@{concat(dataset().schemaName,\'/\',dataset().tableName)}'
          type: 'Expression'
        }
        fileSystem: 'blob2pxferwdtecvaa'
      }
      compressionCodec: 'snappy'
    }
    schema: []
  }
  dependsOn: [
    linkedService
  ]
}
