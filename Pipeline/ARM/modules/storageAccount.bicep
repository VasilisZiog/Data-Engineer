@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string 

@description('Name of the Azure storage account that contains the input/output data.')
param strgVassilis string 

@description('Location of the data factory.')
param location string 

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: strgVassilis
  location: location
  tags: {
    'ms-resource-usage': 'azure-cloud-shell'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}


resource storageAccounts_ecommerce20172018_name_default_dp203 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService //or dependsOn: [blobService]
  name: blobContainerName
}
