#!/bin/bash

# Variables
dataLakeAccountName="$1"
containerName="$2"
accountKey="$3"
baseUrl="$4"

# Create a unique timestamp for temporary directory
timestamp=$(date +%s)
tempDir="temp_$timestamp"
mkdir "$tempDir"

declare -A csvUrls

csvUrls["msdyn_workorder.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/msdyn_workorder.csv'
csvUrls["incident.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/incident.csv'
csvUrls["msdyn_iotalert.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/msdyn_iotalert.csv'
csvUrls["connection.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/connection.csv'
csvUrls["msdyn_iotdevice.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/msdyn_iotdevice.csv'
csvUrls["msdyn_customerasset.csv"]=${baseUrl}'Deployment/Data/dataverse_d365_generated/msdyn_customerasset.csv'

# Install Azure CLI extension for Data Lake Storage
az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null

az storage fs directory create -n dataverse_d365_generated -f "$containerName" --account-name "$dataLakeAccountName" --account-key "$accountKey" --auth-mode key

# Download CSV files
for url in ${!csvUrls[@]};
do
  outfile=/mnt/azscripts/azscriptinput/${tempDir}/${url}
  curl -L ${csvUrls[${url}]} -o $outfile
  output= az storage fs file upload -s $outfile -p dataverse_d365_generated/$url  -f "$containerName" --account-name "$dataLakeAccountName" --account-key "$accountKey"  --auth-mode key
done