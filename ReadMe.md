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

Key Components:
- Terraform plans for all 3 cloud providers will deploy any combination of multi-chain (Mainnet, Kovan, Avalanche, etc.) Chainlink nodes managed in Kubernetes state files
- fraXses Universal External Adapter. This external adapter will allow Chainlink nodes to authenticate with sandbox


