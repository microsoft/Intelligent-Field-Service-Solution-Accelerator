#!/bin/bash

# Set variables
workspaceName="$1"
keyvaultName="$2"
baseUrl="$3"

az config set extension.use_dynamic_install=yes_without_prompt 2>/dev/null

declare -A notebooks

curl --silent ${baseUrl}'Code/Notebooks/00_load_sample_data.ipynb' --output /mnt/azscripts/azscriptinput/00_load_sample_data.ipynb 
curl --silent ${baseUrl}'Code/Notebooks/01_prepare_training_data.ipynb' --output /mnt/azscripts/azscriptinput/01_prepare_training_data.ipynb 
curl --silent ${baseUrl}'Code/Notebooks/02_train_predictive_maint_model.ipynb' --output /mnt/azscripts/azscriptinput/02_train_predictive_maint_model.ipynb 
curl --silent ${baseUrl}'Code/Notebooks/03_register_model.ipynb' --output /mnt/azscripts/azscriptinput/03_register_model.ipynb 
curl --silent ${baseUrl}'Code/Notebooks/04_run_predictive_maint_inference.ipynb' --output /mnt/azscripts/azscriptinput/04_run_predictive_maint_inference.ipynb 


# Declare an array of notebook files to upload
notebooks["00_load_sample_data"]=/mnt/azscripts/azscriptinput/00_load_sample_data.ipynb 
notebooks["01_prepare_training_data"]=/mnt/azscripts/azscriptinput/01_prepare_training_data.ipynb 
notebooks["02_train_predictive_maint_model"]=/mnt/azscripts/azscriptinput/02_train_predictive_maint_model.ipynb 
notebooks["03_register_model"]=/mnt/azscripts/azscriptinput/03_register_model.ipynb 
notebooks["04_run_predictive_maint_inference"]=/mnt/azscripts/azscriptinput/04_run_predictive_maint_inference.ipynb 

# Loop through the array and upload each notebook
for notebookUrl in ${!notebooks[@]};
do


    notebookFile=/mnt/azscripts/azscriptinput/${notebookUrl}.ipynb

    sed -i "s/ifm-vault/${keyvaultName}/g" $notebookFile

    # Read the JSON file and store the contents in a variable
    # Specify the path to save the JSON file
    #outputFile=${notebookFile}1.ipynb

    # Save the JSON string to the file
    #echo "$jsonString" > "$outputFile"

    # Create or update a Synapse workspace notebook
    output= az synapse notebook create  --workspace-name $workspaceName \
                                        --name $notebookUrl \
                                        --file @$notebookFile \
                                        --spark-pool-name "sparkpoolforml"
done
