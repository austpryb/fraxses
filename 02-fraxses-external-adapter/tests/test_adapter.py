import pytest
import adapter

job_run_id = '1'


def adapter_setup(test_data):
    a = adapter.Adapter(test_data)
    return a.result


@pytest.mark.parametrize('test_data', [
    {'id': job_run_id, 'data': {'action': 'app_qry', 'hed_cde': 'invoices', 'whr': '', 'odr': '', 'pge': 1, 'pge_sze': 1}},
    {'id': job_run_id, 'data': {'action': 'app_qry', 'hed_cde': 'invoices', 'whr': '', 'odr': '', 'pge': 2, 'pge_sze': 1}},
    {'id': job_run_id, 'data': {'action': 'app_qry', 'hed_cde': 'invoices', 'whr': '', 'odr': '', 'pge': 3, 'pge_sze': 1}},
])
def test_create_request_success(test_data):
    result = adapter_setup(test_data)
    print(result)
    assert result['statusCode'] == 200
    assert result['jobRunID'] == job_run_id
    assert result['data'] is not None
    assert type(result['result']) is float
    assert type(result['data']['result']) is float


@pytest.mark.parametrize('test_data', [
    {'id': job_run_id, 'data': {}},
    {'id': job_run_id, 'data': {'action': 'does_not_exist', 'parm1': 'abc123'}},
    {},
])
def test_create_request_error(test_data):
    result = adapter_setup(test_data)
    print(result)
    assert result['statusCode'] == 500
    assert result['jobRunID'] == job_run_id
    assert result['status'] == 'errored'
    assert result['error'] is not None
