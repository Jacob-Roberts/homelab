#!/bin/bash

set -e

PROJECT_ID="$1"
ENVIRONMENT="$2"
SECRET_PATH="$3"

if [ -z "$PROJECT_ID" ] || [ -z "$ENVIRONMENT" ] || [ -z "$SECRET_PATH" ]; then
    echo "Usage: $0 <PROJECT_ID> <ENVIRONMENT> <SECRET_PATH>"
    exit 1
fi

# Check if .env already exists
if [ -f .env ]; then
    echo "✓ .env file already exists. Skipping secret pull."
    exit 0
fi

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


chmod 660 .env

echo "✓ Secrets pulled successfully to .env"
