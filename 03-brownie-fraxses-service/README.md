# Brownie

---

<strong>03-brownie-fraxses-service</strong> project directory has been cloned from the [official](https://github.com/eth-brownie) Brownie repository and adapted to run as a microservice in fraXses.

The Brownie microservice is meant to be run from within an existing fraXses cluster and allows developers to access their web3 Brownie session over a REST API. The service runs in the fraXses mesh, a network of coordinated microservices that orchestrate logical tasks in the cluster. These services communicate over a highly available, highly replicated pubsub framework thus allowing any service ran as an HTTP server or producer/consumer to be hosted in the mesh. A vanilla fraXses implementation is comprised of microservices written in Rust, Scala, Python, C, Java, Julia and more. The kit also includes the fraXses optimized thrift server running Spark 3.0.1 which allows for virtual query federation to nearly 300 different sources of data. Again, all accesible over the fraXses gateway REST API. Because fraXses's tasks are configured as metadata, most of the configuration require litle to no code and is done in the fraXses Configuration platform. 

These capabilities make the Brownie Chainlink mix an interesting proposition for a microservice. Developers can mount their pre-existing Brownie project on a Kubernetes volume into the session already being hosted or opt to port forward into a fresh container from the Kube commandline thus giving direct access to the Brownie project as if it were hosted locally.

What makes this Brownie session different than others is the background producer/consumer processing. The following block of code opens a Python consumer listening to a channel specified in the fraXses metadata database and runs as the ENTRYPOINT/CMD program for the Docker container. This program perpetually listens for incoming messages coming from the fraXses coordinator. 

#### Refer to  <strong>03-brownie-fraxses-service/deployments/deployment-manifest.py</strong>
This script will use JINJA2 template to auto generate the Kubernetes deployment files. This is useful for embedding environment variables into the container so your Brownie session has access. You could extend this functionality to use Kubernetes secrets as well. 
```
# The contents of 03-brownie-fraxses-service/deployments/exammple_manifest are generated like so
python3 manifest.py test \ 
		    default \
		    namespace \ 
		    environment \ 
		    web3_infura_project_id \ 
		    web3_infura_project_secret \ 
	            web3_infura_mainnet_wss \
		    web3_infura_mainnet_https \ 
		    web3_infura_kovan_wss \
		    web3_infura_kovan_https \ 
		    wallet_private_key_mainnet \ 
		    wallet_private_key_kovan \
		    version_name mainnet 
```
 
#### Refer to <strong>03-brownie-fraxses-service/dapps/hackathon/app/app.py</strong>
This block of code initiates a Kafka listener looking for messages on TOPIC_NAME and will process messages based on the "handle_message()" function. Technically you could use multiprocessing libary have many listeners for different topics thus serving multiple Brownie endpoints from the same session.
```
if __name__ == "__main__":
    # open the smart wrapper listening context
    wrapper = FraxsesWrapper(group_id="test", topic=TOPIC_NAME) 

    with wrapper as w:
	# iterate through this message batch
        for message in wrapper.receive(FraxsesPayload):
            if type(message) is not WrapperError:
                # now handle the message with some Brownie logic
                task = handle_message(message)
                # respond back to the coordinator
                response = Response(
                    result=ResponseResult(success=True, error=""),
                    payload=task,
                )
                message.respond(response)
            else:
                error = message
                print("Error in wrapper", error.format_error(), message)
```

This block of code imports the project and connects to the chain specified in that projects config. The function, "handle_message()", will do something with the parameters sent in from the coordinator. In this case those parameters get passed into the "deploy_contract()" function, where a contract specifying an NFT is minted.

```
# Gives us access to the Brownie session
from brownie import *
...
# init the Chainlink Brownie project
network.connect('development')
project = project.load('app/chainlink/')
...
def handle_message(message):
    try:
	# parse the payload using the data class schema shown below
        data = message.payload
        data = data.payload
    except Exception as e:
        print("Error in wrapper parsing", str(e))
        return str(e)
    try:
        # If the parameters look okay, there is nothing left to do besides deploy the contract
        deploy = deploy_contract()
        # Just return the same payload that was sent in to indicate success
        return data # Conveniently, you could make the return look like {'jobRunID':data, 'parameters':{'':''}}
    except Exception as e:
        return str(e)
```

Data classes define how the payload (our smart contract parameters) will be parsed. In this case, the data class, "FraxsesPayload" will always stay the same and "SmartContractParameters" can be dynamic and is defined from the fraXses configuration front end.

```
@dataclass
class SmartContractParameters:
    data: str

@dataclass
class FraxsesPayload:
    id: str
    obfuscate: bool
    payload: SmartContractParameters
```

This simple function to compile and deploy the FraXses-Chainlink NFT example

```
def deploy_contract(x):
    try:
        dev = accounts.add(os.getenv(config['wallets']['from_key']))
        deployment = project.FraxsesNft.deploy({'from':dev}) #, publish_source=True)
        return str(deployment) + '|' +str(type(deployment)) + '|'  + str(x)
    except Exception as e:
        return str(e)
```

Finally the fraXses the Chainlink Proof of Concept... WIP



