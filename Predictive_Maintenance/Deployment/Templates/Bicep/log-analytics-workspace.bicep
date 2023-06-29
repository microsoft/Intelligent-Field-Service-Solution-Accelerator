// ========== Log Analytics Workspace ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Log Analytics Workspace Name')
param lawName string = '${ solutionName }-log-analytics-ws'

@description('Managed Identity Type. ')
@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
])
param identityType string = 'UserAssigned'

@description('SKU Name. The name of the SKU.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuName string = 'PerGB2018'

@description('User Assigned Identities. Gets or sets a list of key value pairs that describe the set of User Assigned identities that will be used with this storage account.')
param userAssignedIdentity string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: solutionLocation
  tags: {
    app: solutionName
    location: solutionLocation
  }
  identity: {
    type: identityType
    userAssignedIdentities: {
      '${userAssignedIdentity}' : {}
    }
  }
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: 90
    workspaceCapping: {
      dailyQuotaGb: json('0.025')
    }
  }
}

output logAnalyticsWorkspaceOutput object = {
  id: logAnalyticsWorkspace.id
  name: lawName
}
