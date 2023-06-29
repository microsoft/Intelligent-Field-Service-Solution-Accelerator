// ========== Storage Account ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Name')
param saName string = '${ solutionName }storageaccount'

resource storageAccounts_resource 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: saName
  location: solutionLocation
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccounts_default 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccounts_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_default 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: storageAccounts_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_default 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: storageAccounts_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}


resource storageAccounts_default_storageAccounts_filesys 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccounts_default
  name: 'storagefilesys'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_resource
  ]
}

resource storageAccounts_default_power_platform_dataflows 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccounts_default
  name: 'power-platform-dataflows'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_resource
  ]
}

var storageAccountKeys = listKeys(storageAccounts_resource.id, '2021-04-01')
var storageAccountString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_resource.name};AccountKey=${listKeys(storageAccounts_resource.id, storageAccounts_resource.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'

output storageAccountOutput object = {
  id: storageAccounts_resource.id
  name: saName
  uri: storageAccounts_resource.properties.primaryEndpoints.web  
  dfs: storageAccounts_resource.properties.primaryEndpoints.dfs
  storageAccountName:saName
  key:storageAccountKeys.keys[0].value
  connectionString:storageAccountString
  dataContainer:storageAccounts_default_storageAccounts_filesys.name
}

