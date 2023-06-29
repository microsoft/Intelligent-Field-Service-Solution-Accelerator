keyvaultName="$1"
file_system_name="$2"
data_lake_account_name="$3"
subscription_id="$4"
resource_group="$5"
workspace_name="$6"
service_bus_connection_string="$7"

# Install Azure CLI extension for Data Lake Storage
az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null

az keyvault secret set --vault-name ${keyvaultName} --name file-system-name --value ${file_system_name}
az keyvault secret set --vault-name ${keyvaultName} --name data-lake-account-name --value ${data_lake_account_name}
az keyvault secret set --vault-name ${keyvaultName} --name subscription-id --value ${subscription_id}
az keyvault secret set --vault-name ${keyvaultName} --name resource-group --value ${resource_group}
az keyvault secret set --vault-name ${keyvaultName} --name workspace-name --value ${workspace_name}
az keyvault secret set --vault-name ${keyvaultName} --name service-bus-connection-string --value ${service_bus_connection_string}