@description('Data Factory Name')
param dataFactoryName string 

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 

@description('Name for the key vault')
param vaults_SQLerver_name string 

var pipelineName = 'ArmtemplateSampleCopyPipeline'

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
  dependsOn: [
    keyVaultLinkedService
  ]
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





resource dataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'Look for Sales tables'
        type: 'Lookup'
        dependsOn: []
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'SqlServerSource'
            sqlReaderQuery: 'SELECT s.name AS SchemaName,\r\n\t\tt.name AS TableName\r\nFROM sys.tables t\r\nINNER JOIN sys.schemas s\r\nON t.schema_id=s.schema_id\r\nWHERE s.name=\'Sales\''
            queryTimeout: '02:00:00'
            partitionOption: 'None'
          }
          dataset: {
            referenceName: 'AllTables'
            type: 'DatasetReference'
          }
          firstRowOnly: false
        }
      }
      {
        name: 'ForEachSchemaTable'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Look for Sales tables'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Look for Sales tables\').output.value'
            type: 'Expression'
          }
          activities: [
            {
              name: 'Copy data1'
              type: 'Copy'
              dependsOn: []
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'SqlServerSource'
                  sqlReaderQuery: {
                    value: '@{concat(\'SELECT * FROM \', item().SchemaName,\'.\',item().TableName)}'
                    type: 'Expression'
                  }
                  queryTimeout: '02:00:00'
                  partitionOption: 'None'
                }
                sink: {
                  type: 'ParquetSink'
                  storeSettings: {
                    type: 'AzureBlobFSWriteSettings'
                  }
                  formatSettings: {
                    type: 'ParquetWriteSettings'
                  }
                }
                enableStaging: false
                translator: {
                  type: 'TabularTranslator'
                  typeConversion: true
                  typeConversionSettings: {
                    allowDataTruncation: true
                    treatBooleanAsNumber: false
                  }
                }
              }
              inputs: [
                {
                  referenceName: 'AllTables'
                  type: 'DatasetReference'
                }
              ]
              outputs: [
                {
                  referenceName: 'parquetTables'
                  type: 'DatasetReference'
                  parameters: {
                    schemaName: {
                      value: '@item().SchemaName'
                      type: 'Expression'
                    }
                    tableName: {
                      value: '@item().TableName'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    ]
    annotations: []
  }
  dependsOn: [
    sqlDataset, parquetDataset
  ]
}

output name string = dataFactoryPipeline.name
output resourceId string = dataFactoryPipeline.id
output resourceGroupName string = resourceGroup().name

