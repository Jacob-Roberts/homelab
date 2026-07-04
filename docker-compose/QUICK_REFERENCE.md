# Docker Compose Overrides - Quick Reference

## Deployment Commands

```bash
# Deploy to an environment
./deploy.sh SERVICE ENVIRONMENT up -d
./deploy.sh cadvisor iad1-node-1 up -d

# Stop a service
./deploy.sh SERVICE ENVIRONMENT down

# View logs
./deploy.sh SERVICE ENVIRONMENT logs -f

# Check configuration will merge correctly
./deploy.sh SERVICE ENVIRONMENT config

# Pull latest images
./deploy.sh SERVICE ENVIRONMENT pull

# Restart service
./deploy.sh SERVICE ENVIRONMENT restart
```

## Services Refactored

| Service | Environments | Status |
|---------|-------------|--------|
| cadvisor | iad1-node-1, lhr1-node-1, slc1-node-3 | ✅ Ready |
| portainer | iad1-node-1, sgu1-home-1, lhr1-node-1, slc1-node-3 | ✅ Ready |
| immich | lhr1-node-1, lhr1-workstation-1, slc1-node-3 | ✅ Ready |

## File Structure

```
service-name/
├── compose.yaml                 ← Base (all common config)
├── compose.{env}.yaml          ← Overrides (what differs)
├── compose.{env}.yaml          ← Overrides (what differs)
└── {env}-directories/          ← Data volumes (unchanged)
    └── data/
```

## How Merging Works

1. **Base file** (`compose.yaml`) is loaded first
2. **Override file** (`compose.{env}.yaml`) is loaded second
3. Later values override earlier ones
4. Services/networks/volumes are merged intelligently

### Example

**Base** (compose.yaml):
```yaml
services:
  app:
    labels:
      domain: ${DOMAIN}
```

**Override** (compose.prod.yaml):
```yaml
services:
  app:
    labels:
      domain: ${DOMAIN:-app.prod.com}
```

**Result**: domain label becomes `app.prod.com` unless overridden

## Manual docker compose Usage

```bash
cd docker-compose/cadvisor

# Standard docker compose commands with both files
docker compose \
  -f compose.yaml \
  -f compose.iad1-node-1.yaml \
  up -d

# View merged result
docker compose \
  -f compose.yaml \
  -f compose.iad1-node-1.yaml \
  config

# Follow logs
docker compose \
  -f compose.yaml \
  -f compose.iad1-node-1.yaml \
  logs -f
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Service won't start | `docker compose config` to see merged YAML |
| Wrong domain/URL | Check override file has correct domain |
| Service not found | Verify override file exists: `ls compose.*.yaml` |
| Variable not set | Add to `.env` file in service directory |
| Socket proxy not working | Verify `compose.{env}.yaml` includes socket-proxy service |

## Environment-Specific URLs

| Service | iad1-node-1 | lhr1-node-1 | slc1-node-3 |
|---------|------------|------------|-----------|
| cadvisor | cadvisor.iad1vpn.jakerob.pro | cadvisor.lhr1.jakerob.pro | cadvisor.slc1.jakerob.pro |
| portainer | portainer.iad1vpn.jakerob.pro | portainer.lhr1.jakerob.pro | portainer.slc1.jakerob.pro |
| immich | photos.jakerob.pro | photos.jakerob.pro | photos.autovation.com |

## Common Workflows

### Deploy New Version to Production
```bash
cd docker-compose/immich
docker compose -f compose.yaml -f compose.lhr1-node-1.yaml pull
docker compose -f compose.yaml -f compose.lhr1-node-1.yaml up -d
```

### Check What Changed Before Deploying
```bash
./deploy.sh portainer lhr1-node-1 config
# Review output, then:
./deploy.sh portainer lhr1-node-1 up -d
```

### View Real-Time Logs
```bash
./deploy.sh cadvisor slc1-node-3 logs -f
# Ctrl+C to exit
```

### Migrate to Override System
1. `cd docker-compose/service-name`
2. Compare environment files to find differences
3. Create base `compose.yaml` with common config
4. Create `compose.{env}.yaml` overrides
5. Test: `docker compose config`

## Key Points

- **Base files** stay at service root level
- **Override files** named `compose.{environment}.yaml`
- **Order matters**: base first, then overrides
- **Test always**: Use `docker compose config` before deploying
- **Keep data dirs**: Environment directories still contain volume data

## More Information

- [Full Guide](COMPOSE_OVERRIDES.md)
- [Refactoring Summary](REFACTORING_SUMMARY.md)
- [Docker Docs: Compose Multi-file](https://docs.docker.com/compose/multiple-compose-files/)
