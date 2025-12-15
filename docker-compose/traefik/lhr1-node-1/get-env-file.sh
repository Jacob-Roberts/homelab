#!/bin/bash

set -e

PROJECT_ID="f3732b81-3a85-430d-a547-43b85c363ad6"
ENVIRONMENT="lhr1"
SECRET_PATH="/traefik"

echo "Pulling secrets from Infisical..."

# Check if Infisical CLI is installed
if ! command -v infisical &> /dev/null; then
    echo "Error: Infisical CLI not installed"
    echo "Install using the ansible playbook install-infisical.yaml"
    exit 1
fi

# Pull secrets and create .env file
infisical export \
    --projectId="$PROJECT_ID" \
    --env="$ENVIRONMENT" \
    --path="$SECRET_PATH" \
    --format=dotenv > .env

echo "✓ Secrets pulled successfully to .env"
