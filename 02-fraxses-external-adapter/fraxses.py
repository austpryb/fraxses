import requests
import json
import logging

logging.basicConfig(level=logging.DEBUG)

def usr_aut(gateway, username="", password=""):
    try:
        payload = {
            "token": "",
            "action": "usr_aut",
            "parameters": {
                "user": username,
                "password": password
                }
            }
    except Exception as e:
        app.logger.error(e)
        return None
    auth = requests.post(url = gateway, data = json.dumps(payload))
    if auth.status_code == 200:
        try:
            token = json.loads(auth.content)['result'][0]['serviceresult']['response']#['records'][0]['tok']
            return token
        except Exception as e:
            app.logger.error(str(e))
            return None
    else:
        app.logger.error('Error connecting to {}, response code is '.format(gateway) + str(auth))
        return None

