import requests
import json
import logging

logging.basicConfig(level=logging.DEBUG)

def usr_aut(gateway, username="", password=""):
    try:
        payload = {
            "token": "9098A7DD-E2B4-46C5-9CA0-8A3E0647FBA7",
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

def app_qry(gateway, token="", hed_cde="", whr="", odr="", pge="", pge_sze=""):
    try:
        payload = {
            "token": token,
            "action": "app_qry",
            "parameters": {
                    "hed_cde": hed_cde,
                    "whr": whr,
                    "odr": odr,
                    "pge": pge,
                    "pge_sze": pge_sze
                }
            }
    except Exception as e:
        app.logger.error(e)
        return None
    qry = requests.post(url = gateway, data = json.dumps(payload))
    if qry.status_code == 200:
        data = json.loads(qry.content)['result'][0]['serviceresult']
        return data
    else:
        app.logger.error(qry.content)
        return None

