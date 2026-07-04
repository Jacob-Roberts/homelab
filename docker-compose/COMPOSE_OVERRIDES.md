# Docker Compose Overrides Guide

This directory uses Docker Compose's multi-file composition and override mechanism to manage similar services across different environments while eliminating duplication.

## Structure

Each service directory now follows this pattern:

```
service-name/
├── compose.yaml                      # Base configuration (common to all environments)
├── compose.{environment}.yaml        # Environment-specific overrides
└── {environment}-directories/        # Data volumes (if needed)
    └── data/
```

## Usage

### Basic Deployment

To deploy a service to a specific environment, use multiple `-f` flags:

```bash
cd docker-compose/cadvisor

# Deploy to iad1-node-1
docker compose -f compose.yaml -f compose.iad1-node-1.yaml up -d

# Deploy to lhr1-node-1
docker compose -f compose.yaml -f compose.lhr1-node-1.yaml up -d

# View merged configuration before deploying
docker compose -f compose.yaml -f compose.iad1-node-1.yaml config
```

### Creating Deployment Scripts

You can create a simple wrapper script for convenience:

```bash
#!/bin/bash
SERVICE=$1
ENVIRONMENT=$2

cd "/path/to/docker-compose/$SERVICE"
docker compose -f compose.yaml -f "compose.${ENVIRONMENT}.yaml" up -d
```

### Using with Environment Variables

Override defaults with environment variables:

```bash
CADVISOR_URL=cadvisor.custom.domain docker compose -f compose.yaml -f compose.iad1-node-1.yaml up -d
```

## How Overrides Work

Docker Compose merges files in order, with later files overriding earlier ones:

1. **Base file** (`compose.yaml`): Contains all common configuration
   - Service image, restart policy, resource limits
   - Common volumes, ports, security settings
   - Generic labels (using placeholder variables)
   - Services used by all environments

2. **Override files** (`compose.{environment}.yaml`): Contains only what differs
   - Environment-specific domain names
   - Different services (e.g., socket-proxy in some environments)
   - Alternative connection methods
   - Environment-specific labels/configuration

### Example: Portainer

**Base** (`compose.yaml`): Direct Unix socket connection
```yaml
services:
  portainer:
    command: "-H unix:///var/run/docker.sock"
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock
```

**Override for lhr1-node-1** (`compose.lhr1-node-1.yaml`): Adds socket-proxy
```yaml
networks:
  internal:
    external: false

services:
  portainer:
    command: "-H tcp://socket-proxy:2375"
    networks:
      - frontend
      - internal
  
  socket-proxy:
    image: lscr.io/linuxserver/socket-proxy:latest
    # ... full socket-proxy configuration
```

## Merge Rules

- **Services**: Later files can add new services or override existing ones
- **Environment variables**: Merged (later values override earlier)
- **Labels**: Merged (later values override earlier)
- **Volumes/Networks**: Merged (later values override earlier)
- **Arrays** (ports, depends_on, etc.): Replaced entirely by later values

## Migration Guide

### For Services Already Refactored

| Service | Status | Usage |
|---------|--------|-------|
| cadvisor | ✅ Refactored | `docker compose -f compose.yaml -f compose.{env}.yaml` |
| portainer | ✅ Refactored | `docker compose -f compose.yaml -f compose.{env}.yaml` |
| immich | ✅ Refactored | `docker compose -f compose.yaml -f compose.{env}.yaml` |

### Refactoring a New Service

1. **Identify variations** across environments:
   ```bash
   # Compare two versions
   diff compose1.yaml compose2.yaml
   ```

2. **Create base file** with common config:
   - Extract all common settings
   - Use placeholder variables: `${VARIABLE_NAME}`
   - Include services used by all environments

3. **Create override files** for each environment:
   - Include only differences
   - Replace placeholder values with environment-specific defaults
   - Add environment-specific services

4. **Test the merge**:
   ```bash
   docker compose -f compose.yaml -f compose.{env}.yaml config
   ```

5. **Keep environment directories** for data volumes (if needed)

## Environment Variables

Each service uses environment-specific variables for URLs and configuration:

### Cadvisor
- `CADVISOR_URL`: Override the domain (default: environment-specific)

### Portainer
- `PORTAINER_URL`: Override the domain (default: environment-specific)

### Immich
- `PHOTOS_URL`: Domain for lhr1-node-1 (default: photos.jakerob.pro)
- `PHOTOS_AUTOVATION_COM`: Domain for slc1-node-3 (default: photos.autovation.com)
- `DB_PASSWORD`: Database password
- `DB_USERNAME`: Database username (default: postgres)
- `DOCKER_USER_ID`: Container user ID (default: 2004)

## Best Practices

### ✅ DO

- Keep base files focused on common configuration
- Use environment variables for values that vary
- Document any service-specific deployment requirements
- Test merged configuration before deploying: `docker compose config`
- Keep data volumes organized by environment

### ❌ DON'T

- Duplicate common configuration across override files
- Add new services only in override files without updating base
- Forget to include default variable values in override files
- Hard-code values that should be environment variables

## Advanced Patterns

### Multiple Override Levels

You can chain multiple overrides for progressive customization:

```bash
# Base + cluster + node level overrides
docker compose \
  -f compose.yaml \
  -f compose.cluster-prod.yaml \
  -f compose.node-lhr1.yaml \
  up -d
```

### Conditional Services

Use overrides to add services only for specific environments:

```yaml
# compose.lhr1-node-1.yaml
services:
  socket-proxy:
    image: lscr.io/linuxserver/socket-proxy:latest
    # ... (only included when this override is used)
```

### Hardware Acceleration

Some services support hardware acceleration. Enable it in environment-specific overrides:

```yaml
# compose.gpu-enabled.yaml
services:
  immich-machine-learning:
    image: ghcr.io/immich-app/immich-machine-learning:v3.0.1-cuda
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities:
                - gpu
```

## Troubleshooting

### Configuration Not Merging as Expected

Always validate the final merged configuration:

```bash
docker compose -f compose.yaml -f compose.{env}.yaml config > /tmp/merged.yaml
# Review /tmp/merged.yaml
```

### Override Not Applying

1. Ensure override file name is correct: `compose.{environment}.yaml`
2. Check file order in command: base file first, then overrides
3. Verify YAML syntax: `yamllint compose.{env}.yaml`
4. Remember: file order matters, later files override earlier ones

### Service Dependencies Breaking

If a service depends on another that's only in an override, ensure:
1. The dependency is listed in `depends_on`
2. Both services are loaded (check `config` output)
3. For socket-proxy pattern: portainer override includes internal network

## Related Files

- [Main README](../README.md)
- [Deployment documentation](../docs/)
