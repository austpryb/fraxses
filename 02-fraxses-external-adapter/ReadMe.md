#### The fraXses External Adapter accelerates the ability to expose services or data to the blockchain and provides a low code, configuration framework for hosting and maintaining data and services. Intenda Corp will be piloting a sandbox cluster in the near future.  

If you are a chainlink node operator tired of running custome adapters for every data source or developer looking to monetize your data and serverless functions then get started by setting a bridge name for "fraxses-external-adapter". There is a public facing bridge up for this submission at 0.0.0.0 so feel free to test some of the Postman items to directly against our sandbox gateway before building your own events in fraXses. Note that every event in fraXses is described by an "action" code which is the minimum required external adapter parameter. Additional parameters can be configured in the fraXses front end per event. While the Postman collection will have you authenticate to fraXses using the "usr_aut" action, the fraXses external adapter handles authentication internally. Of course this could be reversed, where the oracle must pass validated token in prior to utilizing fraXses resources over thexternal adapter.

```
{
  "initiators": [
    { "type": "web" }
  ],
  "tasks": [
    { "type": "fraxses-external-adapter",
      "params": {
        "action":"some-simple-event",
        }
     },
  ]
}


{
  "initiators": [
    { "type": "web" }
  ],
  "tasks": [
    { "type": "fraxses-external-adapter",
      "params": {
	"action":"app_qry", 
	"hed_cde":"invoices", 
	"whr":"id = 1", 
	"odr":"", 
	"pge":"1",
        "pge_sze":"1"
	}
     },
  ]
}
```

#### Queries fraXses invoice data object for first row matching invoice_id = 1
#### Services orchestrated: [META] --> [JDBC] --> [{"invoice_amount":"123.90"}]
```
{
  "action":"app_qry",
  "hed_cde":"invoices",
  "odr":"",
  "whr":"invoice_id='1'",
  "pge":"1",
  "pge_sze":"1",
}
```
#### Queries latest price for ETH/USD pair
#### Services orchestrated: [META] --> [JSON] --> [REFORMAT] --> [{"price":"1003.90"}]
```
{
  "action":"get_eth_usd_price",
  "from":"ETH",
  "to":"USD"
}
```
### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2
### Services orchestrated: [BROWNIE] 
```
{
  "action":"nft_mnt",
  "nft_nme":"MyNewNft",
  "parm1":"abc123",
  "parm2":"789xyz"
}
```

### Mints an NFT token, passing in parameters nft_nme, parm1, and parm2, while also storing a hash of the metadata on chain. The JSON result could be stored on IPFS or sold to another smart contract that has a method for accessing fraXses resources.
### Services orchestrated: [META] --> [BROWNIE] --> [IPFS]
```
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
```

