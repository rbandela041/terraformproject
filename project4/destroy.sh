#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./destroy.sh <workspace>"
  exit 1
fi

# Select the correct workspace
terraform workspace select "$ENV"

# Init with correct backend config
terraform init -reconfigure -backend-config="backend-$ENV.conf"

# Destroy the infra
terraform destroy -var-file="$ENV.tfvars" -auto-approve
