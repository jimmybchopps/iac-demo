#!/bin/bash

#Generate Unique ID and Grab Public IP Address
export TF_VAR_uuid=$(uuidgen)
export TF_VAR_my_ip=$(curl -s https://wtfismyip.com/text)/32

#Replace Unique ID in AWS Inventory File
sed -i 's/tag:UUID: .*/tag:UUID: '"$TF_VAR_uuid"'/g' ansible/aws_ec2.yaml

#Init Terraform and Build the environment
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

#If specifying a large amount of instances consider using parallelism parameter to speed up terraform (example below)
#terraform -chdir=terraform apply -parallelism 25 -auto-approve

#Change permissions on key
chmod 400 access/ec2_key.pem

#Set variable so ansible knows where to look for configuration values
export ANSIBLE_CONFIG=$PWD/ansible/ansible.cfg

#Run the playbook
ansible-playbook ./ansible/main.yml