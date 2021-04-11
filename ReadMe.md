# Chainlink and fraXses Data Mesh Integration. The start of the fastest, most scalable defi data and microservice exchange platform

The goal of this hackathon submission is to demonstrate a production grade multi-chain Chainlink node managing pool that has a tight integration with Intenda's Data Mesh platform, [fraXses](https://www.intenda.tech/fraxses/) over a custom fitted external adapter for the fraXses API Gateway. This integration allows authenticated Chainlink nodes to access resources from a fraXses cluster over a "Universal" external adapter. Universal, because fraXses can translate over 300 unique data source types and orchestrate data exchange between any microservice task wrapped in its mesh. Node operators can configure data interchange from virtually any source or service... all with low or no code. Because fraXses's orchestration layer is built on metadata, enourmous amounts of data or very complex transactions tied to multiple systems can be represented in just a few bytes (03-brownie-fraxses-service/dapp). Metadata updates can be traded, sold, or broadcasted to other fraXses clusters with the push of a button (or invocation by a smart contract). Metadata is portable. It can be minted onto NFT tokens using the Brownie wrapper for fraXses (see part 2), validated on chain by other smart contracts connected to a fraXses mesh, or passed as parameters into pre-compiled solidity (see 03-brownie-fraxses-service).

[Video Walkthrough](https://youtu.be/MJ4Ve0Hknl0)

#### Key Submission Components:
<strong>01-chainlink-operator-node-pool</strong>
- Quickly deploy a 3 node Kubernetes cluster running the Chainlink Node Pool + Postgres, fraXses External Adapter, AvalancheGo Node 
- Advanced users can get started by deploying the Chainlink Node Pool cluster on one of the provided Terraform projects provided in this repo.  
  - Multi-chain orchestration is easily managed by the Kubernetes config maps. Just extend the environment variables to create deployments for MAINNET, KOVAN, AVALANCHE, ETC.

<strong>02-fraxses-external-adapter</strong>
- Node operators can get started by running the fraXses External Adapter on their preferred hosting environment and applying for fraXses Gateway access (https://sandbox.fraxses.com/api/gateway/). Operators can then configure data sources or REST API calls to their favorite providers using the configuration GUI

Temporary FraXses Login (expires 4/16/2021)

```
https://sandbox.fraxses.com/
https://sandbox.fraxses.com/api/gateway/
- u: chainlink_node_operator
- p: chainlink_node_operator
```

<strong>03-brownie-fraxses-service</strong>
- Node operating teams can inquire about running the stack themselves (fraXses + Brownie Microservice + Universal External Adapter + Chainlink Node Pool)
- Microservice developers and data owners can wrap their product in fraXses endpoints to distribute to node operators running the Universal External Adapter.

<strong>04-avalanchego</strong>
- AvalancheGo node conveniently running side by side the Chainlink node pool
- This is the official AvalancheGo build, only modified to run in Kubernetes
