#!/bin/bash
# Deploy a service to a specific environment using docker compose overrides
# Usage: ./deploy.sh SERVICE_NAME ENVIRONMENT [COMMAND]
# Example: ./deploy.sh cadvisor lhr1-node-1 up -d

set -e

SERVICE=${1:-}
ENVIRONMENT=${2:-}
COMMAND=${3:-up -d}

# Validation
if [[ -z "$SERVICE" ]] || [[ -z "$ENVIRONMENT" ]]; then
    cat << 'EOF'
Docker Compose Deploy Helper - Using Overrides

Usage:
    ./deploy.sh SERVICE_NAME ENVIRONMENT [COMMAND]

Examples:
    ./deploy.sh cadvisor iad1-node-1 up -d
    ./deploy.sh portainer lhr1-node-1 logs -f
    ./deploy.sh immich slc1-node-3 down
    ./deploy.sh immich lhr1-node-1 config    # View merged configuration

Services with Overrides:
    - cadvisor (iad1-node-1, lhr1-node-1, slc1-node-3)
    - portainer (iad1-node-1, sgu1-home-1, lhr1-node-1, slc1-node-3)
    - immich (lhr1-node-1, lhr1-workstation-1, slc1-node-3)

Common Commands:
    up -d           Start service in background
    down            Stop service
    logs -f         Follow logs
    config          View merged configuration
    pull            Pull new images
    restart         Restart service

EOF
    exit 1
fi

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$SERVICE"

# Validate service directory
if [[ ! -d "$SERVICE_DIR" ]]; then
    echo "❌ Service directory not found: $SERVICE_DIR"
    exit 1
fi

# Validate compose files
BASE_FILE="$SERVICE_DIR/compose.yaml"
OVERRIDE_FILE="$SERVICE_DIR/compose.${ENVIRONMENT}.yaml"

if [[ ! -f "$BASE_FILE" ]]; then
    echo "❌ Base compose file not found: $BASE_FILE"
    exit 1
fi

if [[ ! -f "$OVERRIDE_FILE" ]]; then
    echo "❌ Override file not found: $OVERRIDE_FILE"
    echo "   Available environments in $SERVICE:"
    ls "$SERVICE_DIR"/compose.*.yaml 2>/dev/null | xargs -n1 basename | sed 's/compose\.\(.*\)\.yaml/   - \1/' || echo "   (none found)"
    exit 1
fi

echo "📦 Service: $SERVICE"
echo "🌍 Environment: $ENVIRONMENT"
echo "🔧 Command: $COMMAND"
echo ""

# Show what will happen
if [[ "$COMMAND" == "config" ]]; then
    echo "📋 Merged configuration:"
    echo "---"
fi

# Execute
cd "$SERVICE_DIR"
docker compose \
    -f compose.yaml \
    -f "compose.${ENVIRONMENT}.yaml" \
    $COMMAND

if [[ "$COMMAND" == "up -d" ]]; then
    echo ""
    echo "✅ Service started!"
    echo ""
    echo "View status:        docker compose -f $BASE_FILE -f $OVERRIDE_FILE ps"
    echo "View logs:          docker compose -f $BASE_FILE -f $OVERRIDE_FILE logs -f"
    echo "View config:        docker compose -f $BASE_FILE -f $OVERRIDE_FILE config"
fi
