#### 02-fraxses-external-adapter project directory has been cloned from the Chainlink Python template [repository](https://github.com/thodges-gh/CL-EA-Python-Template)

It has been modified to resolve external adapter requests into fraXses's API Gateway and is being hosted in the default configuration from <strong>01-chainlink-operator-node-pool</strong>. 
The fraXses External Adapter accelerates the ability to expose services or data to the blockchain and provides a low code, configuration framework for hosting and maintaining data and services.

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+01-42-04.png" width="550" title="">
</p>

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+01-41-23.png" width="550" title="">
</p>

Node operators can get started by setting a bridge named, "fraxses-external-adapter" and point it to the sandbox at http://35.231.18.0:8080/ (if you are running in Kubernetes you to refer to the ip by the service name). The Postman collection will be helpful to understand how the API's work. Anyone can get started by running the fraXses external adapter in Docker, AWS Lambda, or Google Functions.

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+15-58-08.png
" width="750" title="">
</p>

The fraXses external adapter can be deployed a few different ways

- Visit <strong>01-chainlink-operator-node-pool/ReadMe.md</strong> to learn how to deploy the External adapter on a Terraform Kubernetes cluster from scratch 
- Already have a Kubernetes cluster? Go to <strong>02-fraxses-external-adapter/deployments</strong>, run the <strong>generate-manifest.py</strong> script and run```kubectl apply -f *.yml``` on each of the config files  
- Want to host on a VM? docker pull and run austpryb/external-adapter:001
- Follow the Chainlink Python template ReadMe.md for directions on how to package for AWS Lambda and Google Functions 


Note that every event in fraXses is described by an "action" code which is the minimum required external adapter parameter. Additional parameters can be configured in the fraXses front end per event. While the Postman collection will have you authenticate to fraXses using the "usr_aut" action, the fraXses external adapter handles authentication internally. 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+01-43-03.png" width="750" title="">
</p>


A minimal event that returns back the same payload submitted to it. 

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-11+01-43-13.png" width="750" title="">
</p>


```
{
  "initiators": [
    { "type": "web" }
  ],
  "tasks": [
    { "type": "fraxses-external-adapter",
      "params": {
        "action":"CHAINLINK_TEST",
        }
     },
  ]
}
```

Inovice query job run success

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+15-59-17.png" width="750" title="">
</p>

```
# Query invoiceid = 1
{
  "initiators": [
    { "type": "web" }
  ],
  "tasks": [
    { "type": "fraxses-external-adapter",
      "params": {
	"action":"app_qry", 
	"hed_cde":"invoices", 
	"whr":"invoiceid = 1", 
	"odr":"", 
	"pge":"1",
        "pge_sze":"1"
	}
     },
  ]
}
```
Invoice result set

<p align="center">
  <img src="https://s3.amazonaws.com/austpryb.io/Screenshot+from+2021-04-10+15-59-11.png" width="750" title="">
</p>

#### Queries fraXses invoice data object for first row matching invoice_id = 1
#### Services orchestrated: [META] --> [JDBC] --> [{"total":"123.90"}]
<p align="center">
  <img src="" width="750" title="">
</p>

#### Queries latest price for ETH/USD pair
#### Services orchestrated: [META] --> [JSON] --> [REFORMAT] --> [{"price":"1003.90"}]
```
#WIP
"params":{
  "action":"get_eth_usd_price",
  "from":"ETH",
  "to":"USD"
}

```
### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2
### Services orchestrated: [BROWNIE] 
```
# WIP
"params":{
  "action":"nft_mnt",
  "nft_nme":"MyNewNft",
  "parm1":"abc123",
  "parm2":"789xyz"
}
```

### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2, while also storing a hash of the metadata on chain. The JSON result could be stored on IPFS or sold to another smart contract that has a method for accessing fraXses resources.
### Services orchestrated: [META] --> [BROWNIE] --> [IPFS]
```
# WIP
"params":{
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
```

