#!/bin/bash

# Set variables
workspaceName="$1"
baseUrl="$2"

declare -A pipelines

curl --silent ${baseUrl}'Deployment/Pipelines/InferencePipeline.json' --output /mnt/azscripts/azscriptinput/InferencePipeline.json 
curl --silent ${baseUrl}'Deployment/Pipelines/TrainingPipeline.json' --output /mnt/azscripts/azscriptinput/TrainingPipeline.json 

pipelines["InferencePipeline"]=/mnt/azscripts/azscriptinput/InferencePipeline.json
pipelines["TrainingPipeline"]=/mnt/azscripts/azscriptinput/TrainingPipeline.json

az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null


# Deploy each Synapse pipeline
for pipelineDefinitionFile in ${!pipelines[@]};
do
    
    
    jsonFile=/mnt/azscripts/azscriptinput/${pipelineDefinitionFile}.json

    output= az synapse pipeline create --workspace-name $workspaceName \
                               --name $pipelineDefinitionFile \
                               --file @$jsonFile
done