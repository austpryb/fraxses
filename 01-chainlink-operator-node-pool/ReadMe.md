#### Chainlink Node Operator Pool 
The Chainlink Node Operator Pool is a Kubernetes implementation of the Chainlink Node stack (node + postgres db), fraXses External Adapter, and the AvalancheGo node. The cluster I'll be showcasing resides in <strong>01-chainlink-operator-node-pool\google</strong> and is configured to run 2x replica of the fraXses External Adapter as well as 2x each Mainnet, Kovan, Binance, Avalanche-Fuji, and Avalanche Chainlink nodes simultaneously. Installing this framework is mostly automated through Terraform and cloud CLI setup.sh. Navigate to your directory of your preferred cloud provider and run the <strong>setup.sh</strong> script. This command line wizard will walk you through setting up the Cloud environment variables required to run the Terraform commands found in <strong>init_plan_apply.sh</strong>. Once Terraform is applied it will take some time to launch the cluster and its deployment pods. The Azure and On-prem directory will get you to a basic configuration just a Kovan Chainlink node and the External adapter. AWS is WIP.


Follow these steps to deploy the Google Terraform plan. The installation environment is run from a docker container to ensure version control

1) 
```
# Install docker from https://docs.docker.com/get-docker/ 
# OPTIONAL - Install docker-compose from https://docs.docker.com/compose/install/
# Dont have docker? Skip to init_plan_apply.sh and use the Cloud shell provided in your cloud portal

# pull the container down 
docker-compose pull

# build and run in the background
# Dont like docker compose? docker pull austpryb/deployment:001 >> docker run austpryb/deployment:001 -v .:/chainlink
docker-compose up -d

# Tells you the name of the running container
# You can kill the container after your install, docker kill <container-name>
docker ps

# Enter an interactive bash shell for the container
docker exec -it cp_backend bash

```

2) At this point you may navigate into <strong>/chainlink/google</strong> and execute ```. ./setup.sh var1 var2 var3```. Lets interrogate setup.sh.

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

2a) Generate an SSH key to pass into the Terraform Kubernetes provider. SAVE THIS KEY and do not accidentally commit to Github.

```
# Generate a key only once and save a copy somewhere
# If you mess you apply your Terraform with a key once, you must apply and destroy the cluster with that key
# Do not accidentally overwrite your key
printf "Enter an SSH keygen secret. \n"

read SSH_SECRET
ssh-keygen -t rsa -b 4096 -N $SSH_SECRET -C $SSH_EMAIL -q -f  ~/.ssh/id_rsa
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
```

2b) Set the region and zone for your cluster. You may need to check your providers website if you do not know your region code.

```
printf "What GCP Region do you want to build the cluster in? (us-east1)\n"
read GCP_REGION

printf "What GCP Zone do you want to build the cluster in? (us-east1-b)\n"
read GCP_ZONE


# Make sure all of your variables were set. You can set them in the command line afterwards if not 
echo "GCP_REGION set to $GCP_REGION"
echo "GCP_ZONE set to $GCP_ZONE"
echo "PROJECT_ID set to $PROJECT_ID"
echo "SA_EMAIL set to $SA_EMAIL"
echo "SSH_EMAIL set to $SSH_EMAIL"
echo "USER_EMAIL set to $USER_EMAIL"
echo "SSH_KEY set to $SSH_KEY"
echo "CLUSTER_NAME set to $CLUSTER_NAME"

```

3) Its time to execute Terraform. Make sure each of the following variables are correctly set. Once you apply Terraform you must continue to use the SSH key that you created in the set up so do not accidentally overwrite the file.

```
#export $PROJECT_ID=""
#export $SA_EMAIL=""
#export $CLUSTER_NAME=""
#export $GCP_REGION=""
#export $GCP_ZONE=""
#export $SSH_EMAIL=""
#export $USER_EMAIL=""
#export $SSH_KEY=""
#export $ETH_URL_KOVAN=""

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

### Terraform will start provisioning your cluster, in the mean time, we need to prepare the work space.

4) Navigate to [Lens](https://k8slens.dev/), download the appropriate Lens client for your OS, and install the Lens Kubernetes IDE. Lens will allow you to manage all of your clusters, apply kubectl commands using the Lens GUI, and monitor your services all in one place.   

4a) To add your cluster, press the <strong>+</strong> button and select the dropdown to include your configuration, ```~./kube/.config```. 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+23-16-49.png" width="750" title="">
</p>

Your cluster will authenticate correctly if you've executed the gcloud credentials command from your local machine or correctly mounted the docker volume on your home directory. Google will require you to configure extra security settings if you generate this file in the Gcloud shell and then download to your local Lens environment.

```gcloud container clusters get-credentials chainlink-node-pool-cluster --zone $GCP_ZONE --project chainlink-node-pool```

5) You should notice unhealthy pods as your services start to come up. Filter your <strong>Namespace</strong> to include <strong>Chainlink</strong> if you do not see any pods at all. 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+23-36-15.png" width="750" title="">
</p>

5a) To fix these, port forward from the Kubernetes cluster to your local. This is a very secure way to interact with your cluster's resources and you should do this instead of exposing external ip addresses when possible. For future reference you can repeat this to interact with any of your cluster's services.

``` kubectl port-forward postgres-0 :5432 -n chainlink```    

<p align="center">
  <img src=""https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+23-48-02.png width="750" title="">
</p>


5b) We need to manually create postgres databases for the additional chainlink nodes until I have added support for the start up script. Use your favorite database client. [DBeaver](https://dbeaver.io/) if you need one. Just right click the connection --> Create --> Datebase --> [chainlink, chainlink-kovan, chainlink-binance, chainlink-avalanche, chainlink-avalanche-fuji] 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+23-51-20.png" width="750" title="">
</p>


5c) Notice how each pod provides details on secrets and environment variables. Reference these for Chainlink Node Operator login and Postgres authentication details 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+23-38-53.png" width="750" title="">
</p>


6) The cluster is healthy when all pods are spinning green. When ready, click one of the chainlink node operators and port forward into the node operator portal. The username and password are held in the secret, ```api-credentials```

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+00-30-10.png" width="750" title="">
</p>

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+00-45-35.png" width="750" title="">
</p>

7) The Avalanche Node IP can be found on the <strong>Network --> Services</strong> tab in Lens. Look for the <strong>avalanchgo-node-elb</strong>. 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+00-34-24.png" width="750" title="">
</p>

~                                                                                         
