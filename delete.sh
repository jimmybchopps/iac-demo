#!/bin/bash
#Set variables to dummy values
export TF_VAR_uuid=""
export TF_VAR_my_ip="0.0.0.0/0"

#Perform Clean Up Activities Here
rm -rf access/ec2_key.pem

#Destroy Infrastructure
terraform -chdir=terraform destroy -auto-approve