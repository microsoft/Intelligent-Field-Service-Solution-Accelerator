
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Aml Workspace Name')
param amlWorkspaceName string = '${ solutionName }-aml-ws'

param storageAccountsExternalid string 
param vaultsExternalid string
param applicationInsightsExternalid string
param registriesExternalid string

param storageAccountName string

resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' = {
  name: amlWorkspaceName
  location: solutionLocation
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Default'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: amlWorkspaceName
    storageAccount: storageAccountsExternalid
    keyVault: vaultsExternalid
    applicationInsights: applicationInsightsExternalid
    hbiWorkspace: false
    v1LegacyMode: false
    containerRegistry: registriesExternalid
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://westus.api.azureml.ms/discovery'
  }
}


output amlWorkspaceOutput object = {
  name: amlWorkspaceName
}
