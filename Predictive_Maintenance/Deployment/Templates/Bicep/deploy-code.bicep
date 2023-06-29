@description('Specifies the location for resources.')
param solutionLocation string 
@secure()
param storageAccountKey string

param workspaceName string
param storageAccountName string

param containerName string
param identity string
param keyVaultName string
param amlworkspace_name string
param identityObjectId string
param baseUrl string
@secure()
param serviceBusConnectionString string

resource synapseAdmin 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'synapseAdmin'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    scriptContent:'''
    az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null
    output= az synapse role assignment create --workspace-name $1 \
    --role "6e4bf58a-b8e1-4cc3-bbf9-d73143322b78" --assignee $2 2>/dev/null
    echo $output > $AZ_SCRIPTS_OUTPUT_PATH
    '''
    arguments: '${workspaceName} ${identityObjectId}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
}

resource keyVaultLinkService 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'keyVaultLinkService'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/create-azkeyvault-linkservice.sh' // deploy-azure-synapse-notebooks.sh
    arguments: '${workspaceName} ${keyVaultName}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
  dependsOn:[synapseAdmin]
}

resource synapseNotebooksDeployment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'synapseNotebooksDeployment'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/deploy-azure-synapse-notebooks.sh' // deploy-azure-synapse-notebooks.sh
    arguments: '${workspaceName} ${keyVaultName} ${baseUrl}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
  dependsOn:[synapseAdmin]
}

resource synapsePipelinesDeployment 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'synapsePipelinesDeployment'
  location:solutionLocation// Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}'  : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/deploy-azure-synapse-pipelines.sh'
    arguments: '${workspaceName} ${baseUrl}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'

  }
  dependsOn:[synapseAdmin,synapseNotebooksDeployment]
}

resource copyDataverse_d365_generatedData 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'copyDataverse_d365_generatedData'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/upload-sample-files.sh' // deploy-azure-synapse-pipelines.sh
    arguments: '${storageAccountName} ${containerName} ${storageAccountKey} ${baseUrl}' // Specify any arguments for the script
    timeout: 'PT5H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
}

resource copyIOT_generatedData 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'copyIOT_generatedData'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/upload_iot_generated_files.sh' // deploy-azure-synapse-pipelines.sh
    arguments: '${storageAccountName} ${containerName} ${storageAccountKey} ${baseUrl}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
}

resource azSecrets 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'azSecrets'
  location: solutionLocation // Replace with your desired location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.25.0'
    primaryScriptUri: '${baseUrl}Deployment/Scripts/add-key-vault-secrets.sh' // deploy-azure-synapse-notebooks.sh
    arguments: '${keyVaultName} ${containerName} ${storageAccountName} ${subscription().subscriptionId} ${resourceGroup().name} ${amlworkspace_name} ${serviceBusConnectionString}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'Always'
  }
}

