#!/bin/bash

# Useful commands for Terraform if you have successfully exported environment variables
# Or Manually set your environment variables
#export $SERVICE_PRINCIPAL=""
#export $SERVICE_PRINCIPAL_SECRET=""
#export $TENANT_ID=""
#export $SUBSCRIPTION_ID=""
#export $SSH_KEY=""
#export $AZURE_REGION=""
#export $CLUSTER_NAME=""

terraform init 

terraform destroy -var project_id=$PROJECT_ID \
    -var sa_email=$SA_EMAIL \
    -var cluster_name=$CLUSTER_NAME \
    -var gcp_region=$GCP_REGION \
    -var gcp_zone=$GCP_ZONE \
    -var user_email=$USER_EMAIL \
    -var ssh_key="$SSH_KEY" \
    -var node_username=$USER_EMAIL \
    -var eth_url_kovan=$ETH_URL_KOVAN

terraform plan -var project_id=$PROJECT_ID \
    -var sa_email=$SA_EMAIL \
    -var cluster_name=$CLUSTER_NAME \
    -var gcp_region=$GCP_REGION \
    -var gcp_zone=$GCP_ZONE \
    -var user_email=$USER_EMAIL \
    -var ssh_key="$SSH_KEY" \
    -var node_username=$USER_EMAIL \
    -var eth_url_kovan=$ETH_URL_KOVAN

terraform apply -var project_id=$PROJECT_ID \
    -var sa_email=$SA_EMAIL \
    -var cluster_name=$CLUSTER_NAME \
    -var gcp_region=$GCP_REGION \
    -var gcp_zone=$GCP_ZONE \
    -var user_email=$USER_EMAIL \
    -var ssh_key="$SSH_KEY" \
    -var node_username=$USER_EMAIL \
    -var eth_url_kovan=$ETH_URL_KOVAN

