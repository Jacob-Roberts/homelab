#!/bin/bash

# Enable strict error handling
set -e
set -u
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" >&2
    fi
}

# Usage function
show_usage() {
    echo "Usage: $0 [OPTIONS] <PROJECT_ID> <ENVIRONMENT> <SECRET_PATH>"
    echo ""
    echo "Options:"
    echo "  -f, --force     Overwrite existing .env file"
    echo "  -b, --backup    Create backup of existing .env file before overwriting"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Arguments:"
    echo "  PROJECT_ID      Infisical project ID (UUID format)"
    echo "  ENVIRONMENT     Environment name (e.g., prod, dev, staging)"
    echo "  SECRET_PATH     Path to secrets in Infisical (e.g., /app/database)"
    echo ""
    echo "Examples:"
    echo "  $0 f3732b81-3a85-430d-a547-43b85c363ad6 prod /lhr1-node-2/pihole"
    echo "  $0 --force f3732b81-3a85-430d-a547-43b85c363ad6 dev /app/config"
}

# Parse command line options
FORCE=false
BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Validate required arguments
if [ $# -ne 3 ]; then
    log_error "Incorrect number of arguments provided"
    show_usage
    exit 1
fi

PROJECT_ID="$1"
ENVIRONMENT="$2"
SECRET_PATH="$3"

# Validate PROJECT_ID format (should be a UUID)
if ! [[ "$PROJECT_ID" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    log_error "Invalid PROJECT_ID format. Expected UUID format."
    log_error "Example: f3732b81-3a85-430d-a547-43b85c363ad6"
    exit 1
fi

# Validate ENVIRONMENT format
if ! [[ "$ENVIRONMENT" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    log_error "Invalid ENVIRONMENT format. Should start with a letter and contain only letters, numbers, hyphens, and underscores."
    exit 1
fi

# Validate SECRET_PATH format
if ! [[ "$SECRET_PATH" =~ ^/.* ]]; then
    log_error "Invalid SECRET_PATH format. Path should start with '/'."
    exit 1
fi

log_debug "PROJECT_ID: $PROJECT_ID"
log_debug "ENVIRONMENT: $ENVIRONMENT"
log_debug "SECRET_PATH: $SECRET_PATH"
log_debug "FORCE: $FORCE"
log_debug "BACKUP: $BACKUP"

# Check if .env already exists
if [ -f .env ]; then
    if [ "$FORCE" = false ]; then
        log_info ".env file already exists. Use --force to overwrite or --backup to create backup."
        exit 0
    else
        if [ "$BACKUP" = true ]; then
            BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
            log_info "Creating backup: $BACKUP_FILE"
            cp .env "$BACKUP_FILE"
            log_info "Backup created successfully"
        fi
        log_warn "Overwriting existing .env file"
    fi
fi

# Check if Infisical CLI is installed
if ! command -v infisical &> /dev/null; then
    log_error "Infisical CLI not installed"
    log_info "Install using the ansible playbook install-infisical.yaml"
    exit 1
fi

# Check Infisical CLI version
INFISICAL_VERSION=$(infisical --version 2>/dev/null | head -n1 || echo "unknown")
log_debug "Infisical CLI version: $INFISICAL_VERSION"

log_info "Pulling secrets from Infisical..."
log_info "Project: $PROJECT_ID"
log_info "Environment: $ENVIRONMENT"
log_info "Path: $SECRET_PATH"

# Create temporary file for atomic write
TEMP_ENV=".env.tmp.$$"
trap 'rm -f "$TEMP_ENV"' EXIT

# Pull secrets and create .env file
if infisical export \
    --projectId="$PROJECT_ID" \
    --env="$ENVIRONMENT" \
    --path="$SECRET_PATH" \
    --format=dotenv > "$TEMP_ENV"; then
    
    # Validate that we got some content
    if [ ! -s "$TEMP_ENV" ]; then
        log_error "No secrets found or export returned empty content"
        log_info "Check that the project ID, environment, and path are correct"
        exit 1
    fi
    
    # Move temp file to final location atomically
    mv "$TEMP_ENV" .env
    
    # Set appropriate permissions (owner read/write, group read/write, others no access)
    chmod 660 .env
    
    # Count the number of secrets
    SECRET_COUNT=$(grep -c '^[^#].*=' .env || echo "0")
    
    log_info "Secrets pulled successfully to .env"
    log_info "Found $SECRET_COUNT environment variables"
    log_info "File permissions set to 660 (owner: rw-, group: rw-, other: ---)"
else
    log_error "Failed to pull secrets from Infisical"
    log_info "Please check your project ID, environment, and path"
    exit 1
fi
