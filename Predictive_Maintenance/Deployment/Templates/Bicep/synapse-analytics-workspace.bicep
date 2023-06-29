
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Name')
var sawName = '${ solutionName }-synapse-ws'

@description('Data Lake Storage Account URL.')
param dlsAccountUrl string = ''

@description('Data Lake Storage File System.')
param dlsFileSystem string = ''

@description('Data Lake Storage Resource Id. ARM resource Id of this storage account')
param dlsResourceId string


param userAssignedIdentity string

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: sawName
  location: solutionLocation
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity}' : {}
    }
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: dlsResourceId
      createManagedPrivateEndpoint: false
      accountUrl: dlsAccountUrl
      filesystem: dlsFileSystem
    }
    encryption: {
    }
    sqlAdministratorLogin: 'sqladminuser'
    privateEndpointConnections: []
    publicNetworkAccess: 'Enabled'
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: true

  }
}

resource Microsoft_Synapse_workspaces_azureADOnlyAuthentications_workspaces_default 'Microsoft.Synapse/workspaces/azureADOnlyAuthentications@2021-06-01' = {
  parent: synapseWorkspace
  name: 'default'
  properties: {
    azureADOnlyAuthentication: false
  }
}

resource workspaces_sparkpoolforml 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: 'sparkpoolforml'
  location: solutionLocation
  properties: {
    sparkVersion: '2.4'
    nodeCount: 10
    nodeSize: 'Medium'
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    isComputeIsolationEnabled: false
    sessionLevelPackagesEnabled: false
    dynamicExecutorAllocation: {
      enabled: false
    }
    isAutotuneEnabled: false
    provisioningState: 'Succeeded'
  }
}

resource Microsoft_Synapse_workspaces_dedicatedSQLminimalTlsSettings_workspaces_default 'Microsoft.Synapse/workspaces/dedicatedSQLminimalTlsSettings@2021-06-01' = {
  parent: synapseWorkspace
  name: 'default'
  properties: {
    minimalTlsVersion: '1.2'
  }
}


resource workspaces_allowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource workspaces_allowAllAzure 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: 'AllowAllWindowsAzureIps'
  parent: synapseWorkspace
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource workspaces_AutoResolveIntegrationRuntime 'Microsoft.Synapse/workspaces/integrationruntimes@2021-06-01' = {
  parent: synapseWorkspace
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}



@description('This is the built-in Key Vault Administrator role.')
resource storageBlobContributor 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource storageBlobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, guid(sawName), storageBlobContributor.id)
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId:storageBlobContributor.id
    principalType: 'ServicePrincipal' 
  }
}

@description('This is the built-in Service Bus Data Sender role.')
resource sbdataSender 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
}

resource sbdataSenderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, guid(sawName), sbdataSender.id)
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId:sbdataSender.id
    principalType: 'ServicePrincipal' 
  }
}


@description('This is the built-in Key Vault Administrator role.')
resource kvAdminRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, synapseWorkspace.id, kvAdminRole.id)
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId:kvAdminRole.id
    principalType: 'ServicePrincipal' 
  }
}

@description('This is the built-in Azure ML Data Scientist role.')
resource amlDataScientist 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
}

resource amlDataScientistroleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, synapseWorkspace.id, amlDataScientist.id)
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId:amlDataScientist.id
    principalType: 'ServicePrincipal' 
  }
}



output SynapseOutput object = {
  name: sawName
  synapseIdentity: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/systemAssignedIdentities/${sawName}'
}



