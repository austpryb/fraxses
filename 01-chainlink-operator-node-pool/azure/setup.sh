#!/bin/bash

RED='\033[1;31m'
BLUE='\033[1;34m'
normal=$(tput sgr0)
if [ "$#" -ne 2 ]; then
    printf "${RED}please pass the name of the Azure Resource Group you want to create and the desired Chainlink Admin Email\nExample: az login | az account list -o table\n${normal}"
    exit 1
fi

# Set up config
az config set extension.use_dynamic_install=yes_without_prompt
SSH_EMAIL=$1
printf  "Logging into Azure, press any key to continue..."  
read CONTINUE

#if [[ $(az account list) ]]
#then
#    az login -o json
#fi
az login 

TENANT_ID_JSON=$(az account show -o json)
TENANT_ID=$(echo $TENANT_ID_JSON | jq -r '.tenantId') #.[].tenantId
SUBSCRIPTION_ID=$(az account subscription list --query [].subscriptionId --output tsv)

echo SUBSCRIPTION_ID=$SUBSCRIPTION_ID
printf "Azure Resource Group created, setting Azure Subscription to ${BLUE}$SUBSCRIPTION_ID\n${normal}"
az account set --subscription $SUBSCRIPTION_ID

# Create Resource Group in Region Code
RESOURCEGROUP=$2
printf "Which Azure region do you want to deploy the chainlink node pool? (eastus, westus, etc.)?\n"
read AZURE_REGION
#az group create -n $RESOURCEGROUP -l $AZURE_REGION
#printf "Azure Resource Group created, setting Azure Subscription to ${BLUE}$SUBSCRIPTION_ID\n${normal}"

# Set Service Principal (equivalent to service account)
SERVICE_PRINCIPAL_NAME="http://$RESOURCEGROUP-sp"
printf "Creating Azure Service Principal, $SERVICE_PRINCIPAL_NAME\n"
SERVICE_PRINCIPAL_JSON=$(az ad sp create-for-rbac --skip-assignment --name $SERVICE_PRINCIPAL_NAME -o json)
SERVICE_PRINCIPAL=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.appId')
SERVICE_PRINCIPAL_SECRET=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.password')
az role assignment create --assignee $SERVICE_PRINCIPAL \
--scope "/subscriptions/$SUBSCRIPTION_ID" \
--role Contributor

# Generate a key only once
printf "Enter an SSH keygen secret. \n"

read SSH_SECRET
ssh-keygen -t rsa -b 4096 -N $SSH_SECRET -C $SSH_EMAIL -q -f  ~/.ssh/id_rsa
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

printf "Key generated for Chainlink admin username: ${BLUE}$SSH_EMAIL\n${normal}\n"

# For Terraform arg to name kubernetes cluster 
CLUSTER_NAME="$RESOURCEGROUP-cluster"

# Skip the preceding steps up until this point and then override the variables passed into Terraform if you already have service account credentials and resource group set up.
#echo "SERVICE_PRINCIPAL set to  $SERVICE_PRINCIPAL"
#echo "SERVICE_PRINCIPAL_SECRET set to  $SERVICE_PRINCIPAL_SECRET"
#echo "TENANT_ID set to $TENANT_ID"
#echo "SUBSCRIPTION_ID set to $SUBSCRIPTION_ID"
#echo "SSH_KEY set to $SSH_KEY"
#echo "AZURE_REGION set to  $AZURE_REGION"
#echo "CLUSTER_NAME set to $CLUSTER_NAME"
#echo "RESOURCEGROUP set to  $RESOURCEGROUP"
#printf "\n"

export SERVICE_PRINCIPAL=$SERVICE_PRINCIPAL
export SERVICE_PRINCIPAL_SECRET=$SERVICE_PRINCIPAL_SECRET
export TENANT_ID=$TENANT_ID
export SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export SSH_KEY="$SSH_KEY"
export AZURE_REGION=$AZURE_REGION
export CLUSTER_NAME=$CLUSTER_NAME
export RESOURCEGROUP=$RESOURCEGROUP
export USER_EMAIL=$SSH_EMAIL
echo "All Terraform variables are saved"

# Now run these Terraform commands
echo "To deploy your chainlink node pool Kubernetes framework run the commands found in init_plan_apply.sh"
