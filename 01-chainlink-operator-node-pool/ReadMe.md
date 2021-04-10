#### Chainlink Node Operator Pool - Infastructure Set Up
The Chainlink Node Operator Pool is a Kubernetes implementation of the Chainlink Node stack (node + postgres db), fraXses External Adapter, and the AvalancheGo node. The cluster I'll be showcasing resides in <strong>01-chainlink-operator-node-pool\google</strong> and is configured to run 2x replica of the fraXses External Adapter as well as 2x each Mainnet, Kovan, Binance, Avalanche-Fuji, and Avalanche Chainlink nodes simultaneously. Installing this framework is mostly automated through Terraform and cloud CLI setup.sh. Navigate to your directory of your preferred cloud provider and run the <strong>setup.sh</strong> script. This command line wizard will walk you through setting up the Cloud environment variables required to run the Terraform commands found in <strong>init_plan_apply.sh</strong>. Once Terraform is applied it will take some time to launch the cluster and its deployment pods. The Azure and On-prem directory will get you to a basic configuration... just Kovan Chainlink and External adapter running. AWS is WIP.


```
# The installation environment is run from a docker container to ensure version control 
# Install docker from https://docs.docker.com/get-docker/ 
# OPTIONAL - Install docker-compose from https://docs.docker.com/compose/install/
# Dont have docker? Use the Cloud shell provided in your provider's cloud portal browser
# Dont like docker compose? docker pull austpryb/deployment:001 >> docker run austpryb/deployment:001 -v .:/chainlink

# pull the container down 
docker-compose pull

# build and run in the background
docker-compose up -d

# Tells you the name of the running container
# You can kill the container after your install, docker kill <container-name>
docker ps

# Enter an interactive bash shell for the container
docker exec -it cp_backend bash

```

At this point you may navigate into <strong>/chainlink/google</strong>. Lets interrogate <strong>setup.sh</strong>. Notice that the setup script takes 3 variables

```
# make sure exactly 3 vars were passed
if [ "$#" -ne 3 ]; then
    printf "${RED}please pass the name of the Google Cloud proejct you want to create and the desired Chainlink Admin Email\nExample: gcloud auth login | gcloud projects list\n${normal}"
    exit 1
fi

# . ./setup.sh chainlink-node-pool gcp-account@gmail.com wss://mainnet.infura.io/ws/v3/mainnet-id
# We will just be configuring the entire node pool to run eth kovan for the purposes of the POC
# To extend to mainnet and other chain just add the wss/http URL in /chainlink/google/variables.tf and /chainlink/google/modules/k8s/variables.tf
# You would then add using the $4, $5, $6, etc. argument

# Pass in the Google project id where you want your cluster ... 
PROJECT_ID=$1
# Used to login into the node's web portal
USER_EMAIL=$2
# The wss/http address provided by Infura or access provider
ETH_URL_KOVAN=$3
```

Generate a SSH key to pass into the Terraform Kubernetes provider 

```
# Generate a key only once and save a copy somewhere
# If you mess you apply your Terraform with a key once, you must apply and destroy the cluster with that key
# Do not accidentally overwrite your key
printf "Enter an SSH keygen secret. \n"

read SSH_SECRET
ssh-keygen -t rsa -b 4096 -N $SSH_SECRET -C $SSH_EMAIL -q -f  ~/.ssh/id_rsa
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
```

Set the region and zone for your cluster. You may need to check your providers website if you do not wish to

```
printf "What GCP Region do you want to build the cluster in? (us-east1)\n"
read GCP_REGION

printf "What GCP Zone do you want to build the cluster in? (us-east1-b)\n"
read GCP_ZONE


# Make sure all of your variables were set, set them in the command line afterwards if not 
echo "GCP_REGION set to $GCP_REGION"
echo "GCP_ZONE set to $GCP_ZONE"
echo "PROJECT_ID set to $PROJECT_ID"
echo "SA_EMAIL set to $SA_EMAIL"
echo "SSH_EMAIL set to $SSH_EMAIL"
echo "USER_EMAIL set to $USER_EMAIL"
echo "SSH_KEY set to $SSH_KEY"
echo "CLUSTER_NAME set to $CLUSTER_NAME"

```

You can optionally grab each of these prameters from the cloud console yourself and just set them manually

```
export $PROJECT_ID=""
export $SA_EMAIL=""
export $CLUSTER_NAME=""
export $GCP_REGION=""
export $GCP_ZONE=""
export $SSH_EMAIL=""
export $USER_EMAIL=""
export $SSH_KEY=""
export $ETH_URL_KOVAN=""

# imports required packages 
terraform init

# checks for errors and variables being passed correctly
terraform plan -var project_id=$PROJECT_ID \
    -var sa_email=$SA_EMAIL \
    -var cluster_name=$CLUSTER_NAME \
    -var gcp_region=$GCP_REGION \
    -var gcp_zone=$GCP_ZONE \
    -var user_email=$USER_EMAIL \
    -var ssh_key="$SSH_KEY" \
    -var node_username=$USER_EMAIL \
    -var eth_url_kovan=$ETH_URL_KOVAN

# builds the cluster
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
~                                                                                                                        
```





~                                                                                         
