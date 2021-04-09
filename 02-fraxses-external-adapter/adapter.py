from bridge import Bridge
from fraxses import usr_aut
from local_settings import FRAXSES_API_GATEWAY, FRAXSES_USERNAME, FRAXSES_PASSWORD
import logging

class Adapter:
    base_url = FRAXSES_API_GATEWAY

    def __init__(self, input):
        self.id = input.get('id', '1')
        self.request_data = input.get('data')
        if self.validate_request_data():
            self.bridge = Bridge()
            self.set_params()
            self.create_request()
        else:
            self.result_error('No data provided')

    def validate_request_data(self):
        if self.request_data is None:
            return False
        if self.request_data == {}:
            return False
        if self.request_data.get('action') is None:
            return False
        return True

    def set_params(self):
        self.param = {}
        self.action = self.request_data.get('action')
        self.params = {k:v for k, v in self.request_data.items() if k != 'action'}
        for key, value in self.params.items():
            self.param[value] = self.request_data.get(key)
            if self.param is None:
                break

    def create_request(self):
        try:
            token = usr_aut(gateway=FRAXSES_API_GATEWAY, username=FRAXSES_USERNAME, password=FRAXSES_PASSWORD)
            logging.info('Token success, token is '+ str(token))
            if token:
                token=token['records'][0]['tok']
                params = {
                    "token": token,
                    "action": self.action,
                    "parameters": self.params
                    }
                response = self.bridge.request(self.base_url, params)
                logging.info(params)
                data = response.json()
                logging.info(data)
                self.result = data['result'][0]['serviceresult']['id']
                self.result_success(data = data['result'][0]['serviceresult']['response'], job_run_id = data['result'][0]['serviceresult']['id'])
            else:
                self.result_error('Fraxses gateway failed to authenticate, token is ' + str(token))
        except Exception as e:
            self.result_error(e)
        finally:
            self.bridge.close()

    def result_success(self, data, job_run_id):
        self.result = {
            'jobRunID': self.id,
            'data': data,
            'result': self.result,
            'statusCode': 200,
        }

    def result_error(self, error):
        self.result = {
            'jobRunID': 1,
            'status': 'errored',
            'error': f'There was an error: {error}',
            'statusCode': 500,
        }
