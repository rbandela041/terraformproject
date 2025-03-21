#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./deploy.sh <workspace>"
  exit 1
fi

# Select or create workspace
terraform workspace list | grep -q "^  $ENV$" && \
  terraform workspace select "$ENV" || terraform workspace new "$ENV"

# Init with correct backend config
terraform init -reconfigure -backend-config="backend-$ENV.conf"

# Apply with tfvars
terraform apply -var-file="$ENV.tfvars" -auto-approve
