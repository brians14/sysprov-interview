#!/bin/bash

# Switch to terraforms directory
(cd terraform || return

# Initialize terraform project
terraform init

# Create a changes plan
terraform plan -out main.tfplan

# Apply changes
terraform apply main.tfplan)

# Update ansible's hosts
ip_addr=$(az vm show -d -g amdSysProvGroup -n amdSysProvVM --query publicIps -o tsv)
sudo bash << EOF
     cp /etc/ansible/hosts /etc/ansible/hosts.bck
     printf "[webserver]\n%s" "$ip_addr" > /etc/ansible/hosts
EOF

# Execute Ansible playbook
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/webserver.yaml

printf "WebServer can be accessed at: %s" "$ip_addr"
