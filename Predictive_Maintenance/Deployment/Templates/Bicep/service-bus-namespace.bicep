// ========== Service Bus Namespace ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Name')
param sbnName string = '${ solutionName }-service-bus'

resource namespaces_servicebus_name_resource 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: sbnName
  location: solutionLocation
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource namespaces_servicebus_name_sbmessage 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: namespaces_servicebus_name_resource
  name: 'sbmessage'
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}

var serviceBusEndpoint = '${namespaces_servicebus_name_resource.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, namespaces_servicebus_name_resource.apiVersion).primaryConnectionString

param connections_servicebus_2_name string = '${solutionName}-servicebus-api-conn'
resource connections_servicebus_2_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_servicebus_2_name
  location: solutionLocation
  dependsOn:[namespaces_servicebus_name_resource]
  properties: {
    displayName: sbnName
    customParameterValues: {}
    api: {
      name: 'servicebus'
      displayName: 'Service Bus'
      description: 'Connect to Azure Service Bus to send and receive messages. You can perform actions such as send to queue, send to topic, receive from queue, receive from subscription, etc.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1627/1.0.1627.3238/servicebus/icon.png'
      brandColor: '#c4d5ff'
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis',solutionLocation,'servicebus')
      type: 'Microsoft.Web/locations/managedApis'
    }
    parameterValues: {
      connectionString: serviceBusConnectionString
    }
  }
}

output serviceBusOutput object = {
  name: sbnName
  connectionString:serviceBusConnectionString
}

