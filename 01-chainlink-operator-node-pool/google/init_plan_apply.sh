#!/bin/bash
# Or Manually set your environment variables
# Note that for the hackthon I have opted to pass my kovan ETH url in as the default for all my nodes. 
# To add support for MAINNET or other chains just create variables in the <cloud>/modules/k8s/variables.tf and <cloud>/variables.tf files and pass them into their correct Terraform config
# For any questions on how to do this reach me on Discord @austpryb
export $PROJECT_ID=""
export $SA_EMAIL=""
export $CLUSTER_NAME=""
export $GCP_REGION=""
export $GCP_ZONE=""
export $SSH_EMAIL=""
export $USER_EMAIL=""
export $SSH_KEY=""
export $ETH_URL_KOVAN=""

terraform init


#terraform destroy -var project_id=$PROJECT_ID \
#    -var sa_email=$SA_EMAIL \
#    -var cluster_name=$CLUSTER_NAME \
#    -var gcp_region=$GCP_REGION \
#    -var gcp_zone=$GCP_ZONE \
#    -var user_email=$USER_EMAIL \
#    -var ssh_key="$SSH_KEY" \
#    -var node_username=$USER_EMAIL \
#    -var eth_url_kovan=$ETH_URL_KOVAN

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

# This creates a Kube config at ${HOME}/.kube/config
# Make sure your docker-compose has a volume mounted here or else you will have to copy and paste the Kube config to your local
# If you generate a kube config in the docker container and Lens refuses to authenticate just run the get-credentials command from your local shell 
# run "cat ~/.kube/config" if you want to paste as text
gcloud container clusters get-credentials chainlink-node-pool-cluster --zone $GCP_ZONE --project chainlink-node-pool
