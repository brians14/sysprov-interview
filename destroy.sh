#!/bin/bash

# Switch to terraform's forder
(cd terraform || return
# Destroy plan to destroy infrastructure
terraform plan -destroy -out main.destroy.tfplan

# Destroy infrastructure
terraform apply main.destroy.tfplan
)

sudo bash << EOF
     rm /etc/ansible/hosts
     cp /etc/ansible/hosts.bck /etc/ansible/hosts
EOF
