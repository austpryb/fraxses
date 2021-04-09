# Chainlink and fraXses Data Mesh Integration. The start of the fastest, most scalable defi data and microservice exchange platform

The goal of this hackathon submission is to demonstrate, in two parts, a production grade multi-chain Chainlink node manager that has a tight integration with Intenda's Data Mesh platform, fraXses (https://www.intenda.tech/fraxses/). This integration allows authenticated Chainlink nodes to access resources from a fraXses cluster over the "Universal" external adapter. Universal, because fraXses can translate over 300 unique data source types and orchestrate data exchange between any microservice task wrapped in its mesh. Node operators can configure data interchange from virtually any source or service... all with low or no code. Because fraXses's orchestration layer is built on metadata, enourmous amounts of data or very complex transactions tied to multiple systems can be represented in just a few bytes. Metadata updates can be traded, sold, or broadcasted to other fraXses clusters with the push of a button (or invocation by a smart contract). Metadata is portable. It can be minted onto NFT tokens using the Brownie wrapper for fraXses (see part 2), validated on chain by other smart contracts connected to a fraXses mesh, or passed as parameters into pre-compiled solidity.

- Node operators can get started by running the Universal External Adapter on their preferred hosting environment and applying for fraXses Gateway access (https://sandbox.fraxses.com/api/gateway/). Operators can then configure data sources or REST API calls to their favorite providers using the configuration GUI
- Advanced users can get started by deploying the Universal External Adapter on one of the 3 Terraform projects provided in this repo.  
  - Multi-chain orchestration is easily managed by the Kubernetes config maps. Just extend the environment variables to create deployments for MAINNET, KOVAN, AVALANCHE, ETC.
- Node operating teams can inquire about running the stack themselves (fraXses + Brownie Microservice + Universal External Adapter + Chainlink Node Pool)
- Microservice developers and data owners can wrap their product in fraXses endpoints to distribute to node operators running the Universal External Adapter.

Temporary FraXses Login (expires 4/16/2021) 
https://sandbox.fraxses.com/
- u: chainlink_node_operator
- p: chainlink_node_operator

Chainlink smart contracts pass data into the fraXses external adapter like so:

#### Queries fraXses invoice data object for first row matching invoice_id = 1
#### Services orchestrated: [META] --> [JDBC] --> [{"invoice_amount":"123.90"}]
{
  "action":"app_qry",
  "hed_cde":"invoices",
  "odr":"",
  "whr":"invoice_id='1'",
  "pge":"1",
  "pge_sze":"1",
}

#### Queries latest price for ETH/USD pair
#### Services orchestrated: [META] --> [JSON] --> [REFORMAT] --> [{"price":"1003.90"}]
{
  "action":"get_eth_usd_price",
  "from":"ETH",
  "to":"USD"
}

### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2
### Services orchestrated: [BROWNIE] 
{
  "action":"nft_mnt",
  "nft_nme":"MyNewNft",
  "parm1":"abc123",
  "parm2":"789xyz"
}

### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2, while also storing a hash of the metadata on chain. The JSON result could be stored on IPFS or sold to another smart contract that has a method for accessing fraXses resources.
### Services orchestrated: [META] --> [BROWNIE] --> [IPFS]
{
  "action":"nft_mnt",
  "nft_nme":"MyNewNft",
  "parm1":"abc123",
  "parm2":"789xyz",
  "hed_cde":"invoices",
  "odr":"",
  "whr":"invoice_id='1'",
  "pge":"1",
  "pge_sze":"1",
}


Key Components:
- Terraform plans for all 3 cloud providers will deploy any combination of multi-chain (Mainnet, Kovan, Avalanche, etc.) Chainlink nodes managed in Kubernetes state files
- fraXses Universal External Adapter. This external adapter will allow Chainlink nodes to authenticate with sandbox

I am using Terraform to automate infastructure on all 3 clouds and Kubernetes to manage the fraXses "Universal External Adapter" scaling and provisioning. 

# 01 Deploy Infastructure 
### Azure (AKS), Google (GKE), & AWS (EKS) Terraform Plans (contact @austinp@intenda.us.com for on-prem deployment instructions) Intenda 
# 02 Multi-chain Chainlink Node Pool
# 03 


## Execute setup.sh from the respective Dockerfile 
#### AWS: docker run --rm -it amazon/aws-cli:latest bash
#### Azure: docker run --rm -it microsoft/azure-cli:latest bash
#### Google: docker run --rm -it gcr.io/google.com/cloudsdktool/cloud-sdk:latest bash
