#!/bin/bash

# Variables
zipFileName="msdyn_iothub_generated.zip"
extractedFolder="msdyn_iothub_generated"
storageAccount="$1"
fileSystem="$2"
accountKey="$3"
baseUrl="$4"
zipUrl=${baseUrl}"Deployment/Data/msdyn-iothub_generated/msdyn_iothub_generated.zip"


# Download the zip file
curl --output "$zipFileName" "$zipUrl"

# Extract the zip file
unzip /mnt/azscripts/azscriptinput/"$zipFileName" -d /mnt/azscripts/azscriptinput/"$extractedFolder"

az storage fs directory upload -f "$fileSystem" --account-name "$storageAccount" -s "$extractedFolder" --account-key "$accountKey" --recursive

