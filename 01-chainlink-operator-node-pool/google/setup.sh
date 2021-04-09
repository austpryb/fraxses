#!/bin/bash
RED='\033[1;31m'
BLUE='\033[1;34m'
normal=$(tput sgr0)
if [ "$#" -ne 2 ]; then
    printf "${RED}please pass the name of the Google Cloud proejct you want to create and the desired Chainlink Admin Email\nExample: gcloud auth login | gcloud projects list\n${normal}"
    exit 1
fi

#The ID of the project you just created.
PROJECT_ID=$1
#your email address, used to login into the node's web portal
USER_EMAIL=$2
#the description and name for the Service Account
SA_DESC="Terraform service account"
SA_NAME=terraform-service-account

printf  "Logging into Google Cloud, press any key to continue..."  
read CONTINUE

if [[ ! $(gcloud config list account --format "value(core.account)") ]]
then
    gcloud auth login
fi

PROJECT_LIST=$(gcloud projects list --filter $PROJECT_ID)

if [[ $PROJECT_LIST ]]; then
    echo "$PROJECT_ID already exists"
    gcloud config set project $PROJECT_ID
else
    echo "Creating $PROJECT_ID"
    gcloud projects create $PROJECT_ID
    gcloud config set project $PROJECT_ID
fi

printf "Using Google Cloud Project: ${BLUE}$PROJECT_ID\n${normal}"
printf "Chainlink admin username: ${BLUE}$USER_EMAIL\n${normal}\n"

#enable the required API Services
gcloud services list --available

gcloud services enable compute.googleapis.com --project $PROJECT_ID
gcloud services enable container.googleapis.com --project $PROJECT_ID
gcloud services enable cloudresourcemanager.googleapis.com --project $PROJECT_ID

SA_EMAIL=$(gcloud --project $PROJECT_ID iam service-accounts list \
    --filter="displayName:$SA_DESC" \
    --format='value(email)')

if [ -z "$SA_EMAIL" ]
then
	printf "${BLUE}Creating a Service Account to be used with Terraform\n${normal}...\n"
	#create Service Account
	gcloud iam service-accounts create $SA_NAME --display-name "$SA_DESC" --project $PROJECT_ID
	#SA needs some time to propagate before we can get its email
	sleep 5
	#extract the email from the newly generated Service Account
	SA_EMAIL=$(gcloud --project $PROJECT_ID iam service-accounts list \
	    --filter="displayName:$SA_DESC" \
	    --format='value(email)')
else
	printf "${BLUE}Reusing existing Service Account $SA_EMAIL\n${normal}"
fi	

printf "${BLUE}Generating Service Account Key\n${normal}...\n"

gcloud iam service-accounts keys create key.json --iam-account=$SA_EMAIL

printf "${BLUE}Granting Service Account IAM Access\n${normal}...\n"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SA_EMAIL \
    --role roles/editor

sleep 5

SSH_EMAIL=$USER_EMAIL
# Generate a key only once
printf "Enter an SSH keygen secret. \n"

read SSH_SECRET
ssh-keygen -t rsa -b 4096 -N $SSH_SECRET -C $SSH_EMAIL -q -f  ~/.ssh/id_rsa
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

printf "Key generated for Chainlink admin username: ${BLUE}$SSH_EMAIL\n${normal}\n"


printf "What GCP Region do you want to build the cluster in? (us-east1)\n"
read GCP_REGION

printf "What GCP Zone do you want to build the cluster in? (us-east1-b)\n"
read GCP_ZONE

echo "GCP_REGION set to $GCP_REGION"
echo "GCP_ZONE set to $GCP_ZONE"
echo "PROJECT_ID set to $PROJECT_ID"
echo "SA_EMAIL set to $SA_EMAIL"
echo "SSH_EMAIL set to $SSH_EMAIL"
echo "USER_EMAIL set to $USER_EMAIL"
echo "SSH_KEY set to $SSH_KEY"
echo "CLUSTER_NAME set to $CLUSTER_NAME"
printf "\n"

# For Terraform arg to name kubernetes cluster 
CLUSTER_NAME="$PROJECT_ID-cluster"
export GCP_REGION="$GCP_REGION"
export GCP_ZONE="$GCP_ZONE"
export PROJECT_ID="$PROJECT_ID"
export SA_EMAIL="$SA_EMAIL"
export SSH_EMAIL=$SSH_EMAIL
export USER_EMAIL=$USER_EMAIL
export CLUSTER_NAME=$CLUSTER_NAME
export SSH_KEY="$SSH_KEY"

echo "All Google variables are saved"

echo "To deploy your chainlink node pool Kubernetes framework run the commands found in init_plan_apply.sh"
