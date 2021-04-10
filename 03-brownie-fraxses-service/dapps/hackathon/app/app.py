from brownie import *
import os
import json
import logging
from python_fraxses_wrapper.wrapper import FraxsesWrapper
from dataclasses import dataclass
from python_fraxses_wrapper.error import WrapperError
from python_fraxses_wrapper.response import Response, ResponseResult
from local_settings import ETHERSCAN_TOKEN, ENVIRONMENT, WEB3_INFURA_PROJECT_ID, WEB3_INFURA_PROJECT_SECRET, WEB3_INFURA_MAINNET_WSS, WEB3_INFURA_MAINNET_HTTPS, WEB3_INFURA_KOVAN_WSS, WEB3_INFURA_KOVAN_HTTPS, WALLET_PRIVATE_KEY_MAINNET, WALLET_PRIVATE_KEY_KOVAN 

logging.basicConfig(level=logging.DEBUG)

TOPIC_NAME = "chainlink_brownie_request"

network.connect('development')
project = project.load('app/chainlink/')

@dataclass
class SmartContractParameters:
    data: str

@dataclass
class FraxsesPayload:
    id: str
    obfuscate: bool
    payload: SmartContractParameters

def deploy_contract(x):
    try:
        dev = accounts.add(os.getenv(config['wallets']['from_key']))
        deployment = project.FraxsesNft.deploy({'from':dev}) #, publish_source=True)
        return str(deployment) + '|' +str(type(deployment)) + '|'  + str(x)
    except Exception as e:
        return str(e)

def handle_message(message):
    try:
        data = message.payload
        data = data.payload['data']
        deploy = deploy_contract(data['TEST'])
    except Exception as e:
        print("Error in wrapper parsing", str(e))
        return str(e)
    return {'jobRunID':data['id'], 'parameters':{'':''}}

if __name__ == "__main__":
    wrapper = FraxsesWrapper(group_id="test", topic=TOPIC_NAME) #1000 

    with wrapper as w:
        for message in wrapper.receive(FraxsesPayload):
            if type(message) is not WrapperError:
                task = handle_message(message)
                response = Response(
                    result=ResponseResult(success=True, error=""),
                    payload={task},
                )
                message.respond(response)
                print("Successfully responded to coordinator")
            else:
                error = message
                print("Error in wrapper", error.format_error(), message)
                error.log()


