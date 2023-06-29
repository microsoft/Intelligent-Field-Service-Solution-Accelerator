#!/bin/bash

# Set variables
workspace_name="$1"
key_vault_name="$2"
key_vault_uri="https://${key_vault_name}.vault.azure.net"
json_file_path="keyVault.json"

az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null

# Create the Key Vault-Linked Service
cat <<EOF > $json_file_path
{
  "properties":{
    "type": "AzureKeyVault",
    "typeProperties": {
    "baseUrl": "$key_vault_uri"
    }
  }
}
EOF

output= az synapse linked-service create --workspace-name $workspace_name --name 'ifmpmvault' --file @$json_file_path