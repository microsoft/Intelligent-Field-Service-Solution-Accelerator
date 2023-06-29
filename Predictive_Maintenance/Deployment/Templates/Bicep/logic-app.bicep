//param connections_commondataservice_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/commondataservice'
param connections_servicebus_2_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${solutionName}-servicebus-api-conn'

@description('Solution Location')
param solutionLocation string
@description('Solution Name')
param solutionName string

param CRMOrganizationUniqueName string

param connections_commondataservice_name string = '${solutionName}-commondataservice-api-conn'

var logicAppName = '${solutionName}-logic-app'

resource connections_commondataservice_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_commondataservice_name
  location: solutionLocation
  properties: {
    displayName: 'Dataverse API'
    customParameterValues: {}
    nonSecretParameterValues: {
      'token:grantType': 'code'
    }
    api: {
      name: 'commondataservice'
      displayName: 'Microsoft Dataverse (legacy)'
      description: 'Provides access to the environment database in Microsoft Dataverse.'
      iconUri: 'https://connectoricons-prod.azureedge.net/u/shgogna/globalperconnector-train1/1.0.1639.3312/${connections_commondataservice_name}/icon-la.png'
      brandColor: '#637080'
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis',solutionLocation,'commondataservice')
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}

resource logicApp 'Microsoft.Logic/workflows@2017-07-01' = {
  name: logicAppName
  location: solutionLocation
  dependsOn:[connections_commondataservice_name_resource]
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            frequency: 'Minute'
            interval: 3
          }
          evaluatedRecurrence: {
            frequency: 'Minute'
            interval: 3
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'sbmessage\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      actions: {
        Create_a_new_recordScope: {
          foreach: '@body(\'GetIotMessage\')'
          actions: {
            Switch: {
              runAfter: {}
              cases: {
                'Case_-_Anomaly_Detection': {
                  case: 'Anomaly'
                  actions: {
                    'Create_a_new_record - Simulated Thermostat': {
                      runAfter: {}
                      type: 'ApiConnection'
                      inputs: {
                        body: {
                          msdyn_description: ''
                        }
                        host: {
                          connection: {
                            name: '@parameters(\'$connections\')[\'commondataservice\'][\'connectionId\']'
                          }
                        }
                        method: 'post'
                        path: '/v2/datasets/@{encodeURIComponent(string(\'${CRMOrganizationUniqueName}.crm\'))}/tables/@{encodeURIComponent(string(\'msdyn_iotalerts\'))}/items'
                      }
                    }
                  }
                }
                'Case_-_Predictive_Maintenance': {
                  case: 'PredictiveMaintenance'
                  actions: {
                    'Create_a_new_record - Synapse Inference Pipeline': {
                      runAfter: {}
                      type: 'ApiConnection'
                      inputs: {
                        body: {
                          msdyn_description: ''
                        }
                        host: {
                          connection: {
                            name: '@parameters(\'$connections\')[\'commondataservice\'][\'connectionId\']'
                          }
                        }
                        method: 'post'
                        path: '/v2/datasets/@{encodeURIComponent(string(\'${CRMOrganizationUniqueName}.crm\'))}/tables/@{encodeURIComponent(string(\'msdyn_iotalerts\'))}/items'
                      }
                    }
                  }
                }
              }
              default: {
                actions: {
                  Condition: {
                    actions: {
                      'Create_a_new_record - MXCHIP': {
                        runAfter: {}
                        type: 'ApiConnection'
                        inputs: {
                          body: {
                            msdyn_description: ''
                          }
                          host: {
                            connection: {
                              name: '@parameters(\'$connections\')[\'commondataservice\'][\'connectionId\']'
                            }
                          }
                          method: 'post'
                          path: '/v2/datasets/@{encodeURIComponent(string(\'${CRMOrganizationUniqueName}.crm\'))}/tables/@{encodeURIComponent(string(\'msdyn_iotalerts\'))}/items'
                        }
                      }
                    }
                    runAfter: {}
                    else: {
                      actions: {
                        'Create_a_new_record - Thermostat': {
                          runAfter: {}
                          type: 'ApiConnection'
                          inputs: {
                            body: {
                              msdyn_description: ''
                            }
                            host: {
                              connection: {
                                name: '@parameters(\'$connections\')[\'commondataservice\'][\'connectionId\']'
                              }
                            }
                            method: 'post'
                            path: '/v2/datasets/@{encodeURIComponent(string(\'${CRMOrganizationUniqueName}.crm\'))}/tables/@{encodeURIComponent(string(\'msdyn_iotalerts\'))}/items'
                          }
                        }
                      }
                    }
                    expression: {
                      and: [
                        {
                          equals: [
                            '@item().readingtype'
                            'AccelerometerZ'
                          ]
                        }
                      ]
                    }
                    type: 'If'
                  }
                }
              }
              expression: '@item().readingtype'
              type: 'Switch'
            }
          }
          runAfter: {
            GetIotMessage: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        GetIotMessage: {
          runAfter: {}
          metadata: {
            apiDefinitionUrl: 'https://QueueMessageParserEXPManufacturing1669cac886594d.azurewebsites.net/swagger/docs/v1'
            swaggerSource: 'website'
          }
          type: 'Http'
          inputs: {
            body: {
              ContentData: '@{triggerBody()[\'ContentData\']}'
              ContentEncoding: '@{triggerBody()[\'ContentTransferEncoding\']}'
              ContentType: '@{triggerBody()?[\'ContentType\']}'
            }
            method: 'post'
            uri: 'https://queuemessageparserexpmanufacturing1669cac886594d.azurewebsites.net:443/ParseAMQPMessage'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          commondataservice: {
            connectionId: connections_commondataservice_name_resource.id
            connectionName: '${solutionName}-commondataservice-api-conn'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${solutionLocation}/managedApis/commondataservice'
          }
          servicebus: {
            connectionId: connections_servicebus_2_externalid
            connectionName: '${solutionName}-servicebus-api-conn'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${solutionLocation}/managedApis/servicebus'
          }
        }
      }
    }
  }
}
