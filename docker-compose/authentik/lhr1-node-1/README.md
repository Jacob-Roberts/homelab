# Authentik

## Running

```zsh
docker compose --env-file <(infisical export -e prod --format=dotenv --projectId=318f771f-065c-4de6-9461-6e21fae52fab --path=/lhr1-node-1/authentik --telemetry=false) up -d
```