#!/bin/bash

#Perform Clean Up Activities Here
rm -rf terraform/keys/ec2_key.pem

#Destroy Infrastructure
terraform -chdir=terraform destroy -auto-approve