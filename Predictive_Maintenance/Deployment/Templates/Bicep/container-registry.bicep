// ========== Container Registry ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Solution Name')
param solutionName string

@description('Solution Location')
param solutionLocation string

@description('Name')
param crName string = '${ solutionName }containerregistry'

@description('SKU')
param sku string = 'Standard'

@description('Managed Identity Id. ')
param identityId string = ''

@description('Managed Identity Type. ')
@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
])
param identityType string = 'UserAssigned'

@description('Tenant Id')
param tenantId string = ''

@description('User Assigned Identities. Gets or sets a list of key value pairs that describe the set of User Assigned identities that will be used with this storage account.')
param userAssignedIdentity string

@description('Admin User Enabled. The value that indicates whether the admin user is enabled.')
param adminUserEnabled bool = false

@description('Anonymous Pull Enabled')
param anonymousPullEnabled bool = false

@description('Data EndPoint Enabled. Enables registry-wide pull from unauthenticated clients.')
param dataEndPointEnabled bool = false

/*
@description('Key Vault Identity. The client id of the identity which will be used to access key vault.')
param keyVaultIdentity string = ''

@description('Key Vault Key Identifier. Key vault uri to access the encryption key.')
param keyVaultKeyIdentifier string = ''

@description('Key Vault Status. Indicates whether or not the encryption is enabled for container registry.')
param keyVaultStatus string = 'disabled' 
*/

@description('ARM Audience Token Policy Status. The policy for using ARM audience token for a container registry. Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param armAudienceTokenPolicyStatus string = 'Disabled'

@description('Export Policy Status. The export policy for a container registry.	Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param exportPolicyStatus string = 'Enabled'

@description('Quarantine Policy Status. The quarantine policy for a container registry. Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param quarantinePolicyStatus string = 'Disabled'

@description('Retetion Policy Status. The retention policy for a container registry. Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param retentionPolicyStatus string = 'Disabled'

@description('Retetion Policy Datys. The retention policy for a container registry. Days is the number of days to retain an untagged manifest after which it gets purged.')
param retentionPolicyDays int = 30

@description('Soft Delete Policy Retention Days. The soft delete policy for a container registry. Retention Days is the number of days after which a soft-deleted item is permanently deleted.')
param softDeletePolicyRetentionDays int = 30

@description('Soft Delete Policy Status. The soft delete policy for a container registry. Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param softDeletePolicyStatus string = 'Disabled'

@description('Trust Policy Status. The soft delete policy for a container registry. Status is the value that indicates whether the policy is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param trustPolicyStatus string = 'Disabled'

@description('Trust Policy Type. The content trust policy for a container registry. The type of trust policy.')
param trustPolicyType string = 'Notary'

@description('Public Network Access. Whether or not public network access is allowed for the container registry.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Zone Redundancy. Whether or not zone redundancy is enabled for this container registry.')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string = 'Disabled'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: crName
  location: solutionLocation
  tags: {
    app: solutionName
    location: solutionLocation
  }
  sku: {
    name: sku
  }
  identity: {
    principalId: identityId
    type: identityType
    tenantId: tenantId    
    userAssignedIdentities: {
      '${userAssignedIdentity}' : {}
    }
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    dataEndpointEnabled: dataEndPointEnabled
    /*encryption: {
      keyVaultProperties: {
        identity: keyVaultIdentity
        keyIdentifier: keyVaultKeyIdentifier
      }
      status: keyVaultStatus
    }*/
    policies: {
      azureADAuthenticationAsArmPolicy: {
        status: armAudienceTokenPolicyStatus
      }
      exportPolicy: {
        status: exportPolicyStatus
      }
      quarantinePolicy: {
        status: quarantinePolicyStatus
      }
      retentionPolicy: {
        days: retentionPolicyDays
        status: retentionPolicyStatus
      }
      softDeletePolicy: {
        retentionDays: softDeletePolicyRetentionDays
        status: softDeletePolicyStatus
      }
      trustPolicy: {
        status: trustPolicyStatus
        type: trustPolicyType
      }
    }
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

output containerRegistryOutput object = {
  id: containerRegistry.id
}
