# Infrastructure as Code Demo

A hastily thrown together sample of using terraform to create infrastructure in AWS with Ansible used to provide further configuration in a dynamically built environment.

## Install AWS CLI and configure

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html

## Install Terraform

https://developer.hashicorp.com/terraform/cli/install/apt

## Install Ansible

https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html

## Install Ansible Modules

ansible-galaxy collection install -r ansible/requirements.yml -p ./ansible

## Install Additional Tools Required by AWS Dynamic Inventory

sudo apt install python3-pip

pip3 install boto3

## Helpful Links

### Ansible AWS Dynamic Inventory

https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html

### Jinja Templating

https://jinja.palletsprojects.com/en/latest/templates/

## Useful Ansible Commands

### Verify Inventory

ansible-inventory --graph (Make sure your environment varialbe for ANSIBLE_CONFIG is set to the correct path)

### Discovering Facts

https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html

