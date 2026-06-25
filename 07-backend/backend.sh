#!/bin/bash
component=$1
environment=$2
dnf install ansible -y 
pip3.9 install boto3 botocore
ansible-pull -i localhost, -U https://github.com/nallamsrikanth2/ansible-expense-terraform.git component.yaml -e component=$component -e env=$environment