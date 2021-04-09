from flask import Flask, request, jsonify
import json
from adapter import Adapter

app = Flask(__name__)


@app.before_request
def log_request_info():
    app.logger.debug('Headers: %s', request.headers)
    app.logger.debug('Body: %s', request.get_data())


@app.route('/', methods=['POST','GET'])
def call_adapter():
    if request.method == 'GET':
        return 'true'
    data = json.loads(request.data)
    if data == '':
        data = {}
    adapter = Adapter(data)
    return jsonify(adapter.result)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port='8080', threaded=True)
