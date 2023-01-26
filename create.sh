#!/bin/bash

#Generate Unique ID and Grab Public IP Address
export TF_VAR_uuid=$(uuidgen)
export TF_VAR_my_ip=$(curl -s https://wtfismyip.com/text)/32

#Replace Unique ID in AWS Inventory File
sed -i 's/tag:UUID: .*/tag:UUID: '"$TF_VAR_uuid"'/g' ansible/aws_ec2.yaml

#Start Terraform and Show Plan
terraform -chdir=terraform init && \
terraform -chdir=terraform plan

#Confirm Before Building and Running Ansible
echo "Everything look good?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) terraform -chdir=terraform apply -auto-approve && exit;;
    No ) exit;;
  esac
done

#Change permissions on key
chmod 400 access/ec2_key.pem

#terraform -chdir=terraform apply -auto-approve && ansible-playbook ./ansible/playbooks/main.yml;;