// ========== main.bicep ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(6)
@description('Prefix Name')
param solutionPrefix string

@description('Unique Name for D365 organization.')
param CRMOrganizationUniqueName string = 'unqxxxxxxxxxxx'

var solutionLocation = resourceGroup().location

var baseUrl = 'https://raw.githubusercontent.com/microsoft/Intelligent-Field-Service-Solution-Accelerator/main/Predictive_Maintenance/'

// ========== Managed Identity ========== //
module managedIdentityModule 'managed-identity.bicep' = {
  name: 'managedIdentityDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  scope: resourceGroup(resourceGroup().name)
}

// ========== Key Vault ========== //
module keyvaultModule 'keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    objectId: managedIdentityModule.outputs.managedIdentityOutput.objectId
    tenantId: subscription().tenantId
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

// ========== Storage Account Module ========== //
module storageAccountModule 'storage-account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  scope: resourceGroup(resourceGroup().name)
  dependsOn: [
    keyvaultModule
  ]
}

// ========== Container Registry Module ========== //
module containerRegistryModule 'container-registry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation  
    userAssignedIdentity: managedIdentityModule.outputs.managedIdentityOutput.id
  }
  scope: resourceGroup(resourceGroup().name)
  dependsOn: [
    keyvaultModule
  ]
}


// ========== Log Analytics Workspace Module ========== //
module logsAnalyticsWorkspaceModule 'log-analytics-workspace.bicep' = {
  name: 'logAnalyticsWorkspaceDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    userAssignedIdentity: managedIdentityModule.outputs.managedIdentityOutput.id
  }
  scope: resourceGroup(resourceGroup().name)
} 


// ========== Application Insights Module ========== //
module applicationInsightsModule 'application-insights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    workspaceResourceId: logsAnalyticsWorkspaceModule.outputs.logAnalyticsWorkspaceOutput.Id
  }
  scope: resourceGroup(resourceGroup().name)
  dependsOn: [
    logsAnalyticsWorkspaceModule
  ]
}

// ========== Service Bus Namespace ========== //
module serviceBusNamespaceModule 'service-bus-namespace.bicep' = {
  name: 'serviceBusNamespaceDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
}


// ========== Synapse Analytics Workspace ========== //
module synapseAnalyticsWorkspace 'synapse-analytics-workspace.bicep' = {
  name: 'synapseAnalyticsWorkspaceDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    dlsResourceId: storageAccountModule.outputs.storageAccountOutput.id
    dlsAccountUrl: storageAccountModule.outputs.storageAccountOutput.dfs
    dlsFileSystem: storageAccountModule.outputs.storageAccountOutput.dataContainer
    userAssignedIdentity: managedIdentityModule.outputs.managedIdentityOutput.id
  }
  dependsOn:[keyvaultModule,storageAccountModule]
} 

// ========== Logic App ========== //
module logicApp 'logic-app.bicep' = {
  name: 'logicAppDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    CRMOrganizationUniqueName:CRMOrganizationUniqueName
  }
  dependsOn:[serviceBusNamespaceModule]
}

// ========== Logic App ========== //
module blobStorage 'blob-storage.bicep' = {
  name: 'blobStorageDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  dependsOn:[serviceBusNamespaceModule]
} 

// ========== aml workspace ========== //
module Aml 'aml-workspace.bicep' = {
  name: 'amlWorkspaceDeployment'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    applicationInsightsExternalid:applicationInsightsModule.outputs.applicationInsightsOutput.id
    registriesExternalid:containerRegistryModule.outputs.containerRegistryOutput.id
    storageAccountsExternalid:blobStorage.outputs.blobStorageOutput.id
    vaultsExternalid:keyvaultModule.outputs.keyvaultOutput.id
    storageAccountName:blobStorage.outputs.blobStorageOutput.name

  }
  dependsOn:[blobStorage, applicationInsightsModule,keyvaultModule]
} 

module deployCode 'deploy-code.bicep' = {
  name : 'deployCode'
  params:{
    storageAccountName:storageAccountModule.outputs.storageAccountOutput.name
    workspaceName:synapseAnalyticsWorkspace.outputs.SynapseOutput.name
    solutionLocation: solutionLocation
    containerName:storageAccountModule.outputs.storageAccountOutput.dataContainer
    identity:managedIdentityModule.outputs.managedIdentityOutput.id
    amlworkspace_name:Aml.outputs.amlWorkspaceOutput.name
    keyVaultName:keyvaultModule.outputs.keyvaultOutput.name
    serviceBusConnectionString:serviceBusNamespaceModule.outputs.serviceBusOutput.connectionString
    identityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
    storageAccountKey:storageAccountModule.outputs.storageAccountOutput.key
    baseUrl:baseUrl
  }
  dependsOn:[storageAccountModule,synapseAnalyticsWorkspace]
}

