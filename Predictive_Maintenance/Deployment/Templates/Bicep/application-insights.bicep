// ========== Application Insights ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Project Name')
param solutionName string

@description('Project Location')
param solutionLocation string

@description('Name')
param aiName string = '${ solutionName }-app-insights'

@description('Application Type. Type of application being monitored.')
@allowed([
  'other'
  'web'
])
param applicationType string = 'web'

@description('Log Analytics Workspace Resource Id. Resource Id of the log analytics workspace which the data will be ingested to. This property is required to create an application with this API version.')
param workspaceResourceId string

@description('Disable IP Masking.')
param disableIpMasking bool = false

@description('Disable Local Auth. Disable Non-AAD based auth.')
param disableLocalAuth bool = false

@description('Ingestion Mode. Indicates the flow of the ingestion.')
@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string = 'LogAnalytics'

@description('Public Network Access for Ingestion. The network access type for accessing Application Insights ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Public Network Access for Query. The network access type for accessing Application Insights query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Retention In Days. Retention period in days.')
param retetionInDays int = 90

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: aiName
  location: solutionLocation
  kind: 'web'
  tags: {
    app: solutionName
    location: solutionLocation
  }
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    Flow_Type: 'Bluefield'
    IngestionMode: ingestionMode
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    Request_Source: 'rest'
    RetentionInDays: retetionInDays
    SamplingPercentage: json('0.65')    
  }
}

output applicationInsightsOutput object = {
  id: applicationInsights.id
  name: aiName
}
