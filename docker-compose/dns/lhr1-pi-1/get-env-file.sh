#!/bin/bash

PROJECT_ID="f3732b81-3a85-430d-a547-43b85c363ad6"
ENVIRONMENT="prod"
SECRET_PATH="/lhr1-pi-1/pihole"

../../get-env-file.sh "$PROJECT_ID" "$ENVIRONMENT" "$SECRET_PATH"