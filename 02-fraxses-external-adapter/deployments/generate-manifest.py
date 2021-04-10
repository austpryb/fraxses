from jinja2 import Template
import os 
import sys

root_directory = '/blockchain/brownie/dapps/external_adapter_template/deployments'

def generate_save_directory(directory, file):
    generate_directory = os.path.join(root_directory, directory)
    if not os.path.exists(generate_directory):
        os.makedirs(directory)
    return os.path.join(generate_directory, file)

def generate_pvc(generate_directory, namespace, storage_class_name, version_name):
    with open(generate_save_directory('templates', '01_persistent_volume_claim.yml'), 'r') as f:
        yml = Template(f.read())
        yml = yml.render(namespace=namespace, storage_class_name=storage_class_name, version_name=version_name)
    print('writing kubernetes configuration to', generate_directory)
    with open(generate_directory, 'w+') as f:
        f.write(yml)

def generate_deployment(generate_directory, namespace, image, smtp_username, smtp_password, fraxses_api_gateway, fraxses_username, fraxses_password, version_name):
    with open(generate_save_directory('templates', '02_deployments.yml')) as f:
        yml = Template(f.read())
        yml = yml.render(namespace=namespace, image=image, smtp_username=smtp_username, smtp_password=smtp_password, fraxses_api_gateway=fraxses_api_gateway, fraxses_username=fraxses_username, fraxses_password=fraxses_password, version_name=version_name)
    print('writing kubernetes configuration to', generate_directory)
    with open(generate_directory, 'w+') as f:
        f.write(yml)

def generate_services(generate_directory, namespace, node_port, version_name):
    with open(generate_save_directory('templates', '03_services.yml'), 'r') as f:
        yml = Template(f.read())
        yml = yml.render(namespace=namespace, node_port=node_port, version_name=version_name)
    print('writing kubernetes configuration to', generate_directory)
    with open(generate_directory, 'w+') as f:
        f.write(yml)

def main():
    _01 = generate_save_directory(sys.argv[1], '01_persistent_volume_claim.yml')
    generate_pvc(generate_directory=_01, namespace=sys.argv[2], storage_class_name=sys.argv[3], version_name=sys.argv[11])
    
    _02 = generate_save_directory(sys.argv[1], '02_deployments.yml')
    generate_deployment(generate_directory=_02, namespace=sys.argv[2], image=sys.argv[4], smtp_username=sys.argv[5], smtp_password=sys.argv[6], fraxses_api_gateway=sys.argv[7], fraxses_username=sys.argv[8], fraxses_password=sys.argv[9], version_name=sys.argv[11])

    _03 = generate_save_directory(sys.argv[1], '03_services.yml')
    generate_services(generate_directory=_03, namespace=sys.argv[1], node_port=sys.argv[10], version_name=sys.argv[11])

# sudo python3 manifest.py save_directory namespace storage_class_name image smtp_username smtp_password fraxses_api_gateway fraxses_username fraxses_password node_port version_name
# sudo python3 manifest.py test default default austpryb/external-adapter:001 austinp@*******.com pass*** api.fraxses.com/api/gateway username pass*** 30084 us-east-2
if __name__ == '__main__':
    main()
