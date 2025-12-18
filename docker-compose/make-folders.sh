#!/bin/bash

set -e

# Enable strict error handling
set -u
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Function to check if we need sudo for a directory operation
needs_sudo() {
    local dir="$1"
    local parent_dir
    
    # If directory exists, check if we can write to it
    if [ -d "$dir" ]; then
        [ ! -w "$dir" ]
        return $?
    fi
    
    # If directory doesn't exist, check parent directories up the chain
    parent_dir="$dir"
    while [ "$parent_dir" != "/" ] && [ "$parent_dir" != "." ]; do
        parent_dir="$(dirname "$parent_dir")"
        if [ -d "$parent_dir" ]; then
            [ ! -w "$parent_dir" ]
            return $?
        fi
    done
    
    # Default to needing sudo if we can't determine
    return 0
}

# Function to execute command with sudo if needed
run_with_sudo_if_needed() {
    local cmd="$1"
    shift
    
    # If we're already root, no need for sudo
    if [ "$(id -u)" -eq 0 ]; then
        "$cmd" "$@"
        return $?
    fi
    
    # Try without sudo first
    if "$cmd" "$@" 2>/dev/null; then
        return 0
    fi
    
    # If that failed, try with sudo
    log_warn "Permission denied, retrying with sudo..."
    if command -v sudo >/dev/null 2>&1; then
        sudo "$cmd" "$@"
    else
        log_error "sudo not available and command failed. Please run script as root or install sudo."
        return 1
    fi
}

# Check if we have at least 2 arguments
if [ $# -lt 2 ]; then
    log_error "Insufficient arguments provided"
    echo "Usage: $0 <service_id> <dir1> [dir2] [dir3] ..."
    echo "Example: $0 1001:1001 /app/data /app/logs /app/config"
    exit 1
fi

SERVICE_ID="$1"
shift  # Remove first argument, leaving all directories in $@

# Validate SERVICE_ID format (should be uid:gid or just uid)
if ! [[ "$SERVICE_ID" =~ ^[0-9]+(:([0-9]+|[a-zA-Z_][a-zA-Z0-9_-]*))?$ ]]; then
    log_error "Invalid SERVICE_ID format: $SERVICE_ID"
    echo "SERVICE_ID should be in format 'uid' or 'uid:gid' (e.g., 1001 or 1001:1001)"
    exit 1
fi

# Check if we have any directories to create
if [ $# -eq 0 ]; then
    log_error "No directories specified"
    echo "Usage: $0 <service_id> <dir1> [dir2] [dir3] ..."
    exit 1
fi

log_info "Creating directories for service ID: $SERVICE_ID"

# Create all directories
for DIR in "$@"; do
    if [ -z "$DIR" ]; then
        log_warn "Skipping empty directory path"
        continue
    fi
    
    log_info "Creating directory: $DIR"
    if run_with_sudo_if_needed mkdir -p "$DIR"; then
        log_info "Successfully created: $DIR"
    else
        log_error "Failed to create directory: $DIR"
        exit 1
    fi
done

log_info "Setting ownership to $SERVICE_ID for all directories"

# Set ownership for all directories
for DIR in "$@"; do
    if [ -z "$DIR" ]; then
        continue
    fi
    
    if [ -d "$DIR" ]; then
        log_info "Setting ownership for: $DIR"
        if run_with_sudo_if_needed chown "$SERVICE_ID" "$DIR"; then
            log_info "Successfully set ownership for: $DIR"
        else
            log_error "Failed to set ownership for: $DIR"
            exit 1
        fi
    else
        log_warn "Directory does not exist, skipping ownership change: $DIR"
    fi
done

log_info "All operations completed successfully"
