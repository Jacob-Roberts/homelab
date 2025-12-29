#!/bin/zsh

# Wake-on-LAN script with interactive selection or direct hostname targeting
# Uses Infisical to store and retrieve computer MAC addresses

# Default Infisical configuration
DEFAULT_PROJECT_ID="f3732b81-3a85-430d-a547-43b85c363ad6"
DEFAULT_ENVIRONMENT="prod"
DEFAULT_SECRET_PATH="/global/wake-on-lan"

# Allow override via environment variables
PROJECT_ID=${INFISICAL_PROJECT_ID:-$DEFAULT_PROJECT_ID}
ENVIRONMENT=${INFISICAL_ENVIRONMENT:-$DEFAULT_ENVIRONMENT}
SECRET_PATH=${INFISICAL_SECRET_PATH:-$DEFAULT_SECRET_PATH}

# Function to load computers from Infisical
load_computers_from_infisical() {
    # Check if Infisical CLI is installed
    if ! command -v infisical >/dev/null 2>&1; then
        echo "Error: Infisical CLI not installed!" >&2
        echo "" >&2
        echo "Install using:" >&2
        echo "  macOS: brew install infisical" >&2
        echo "  Linux: Use the ansible playbook install-infisical.yaml" >&2
        echo "" >&2
        exit 1
    fi
    
    # Export secrets from Infisical and parse them
    local secrets
    local error_output
    
    if secrets=$(infisical export \
        --projectId="$PROJECT_ID" \
        --env="$ENVIRONMENT" \
        --path="$SECRET_PATH" \
        --format=dotenv 2>/dev/null); then
        
        if [[ -z "$secrets" ]]; then
            echo "Error: No Wake-on-LAN configuration found in Infisical!" >&2
            echo "" >&2
            echo "Please add computer configurations to Infisical at:" >&2
            echo "  Project ID: $PROJECT_ID" >&2
            echo "  Environment: $ENVIRONMENT" >&2
            echo "  Path: $SECRET_PATH" >&2
            echo "" >&2
            echo "Expected format (one secret per computer):" >&2
            echo "  HOSTNAME1=MAC:AD:DR:ES:S1:11" >&2
            echo "  HOSTNAME2=MAC:AD:DR:ES:S2:22" >&2
            echo "" >&2
            exit 1
        fi
        
        # Parse the dotenv format and return as space-separated key-value pairs
        local result=""
        while IFS='=' read -r hostname mac; do
            # Skip empty lines and comments
            [[ -z "$hostname" || "$hostname" =~ ^[[:space:]]*# ]] && continue
            
            # Remove any surrounding whitespace and quotes
            hostname=$(echo "$hostname" | xargs | sed 's/^"//;s/"$//')
            mac=$(echo "$mac" | xargs | sed 's/^"//;s/"$//')
            
            # Skip if either value is empty
            [[ -z "$hostname" || -z "$mac" ]] && continue
            
            # Validate MAC address format (basic check)
            if [[ ! "$mac" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
                echo "Warning: Invalid MAC address format for $hostname: $mac" >&2
                continue
            fi
            
            result+="[\"$hostname\"]=\"$mac\" "
        done <<< "$secrets"
        
        if [[ -z "$result" ]]; then
            echo "Error: No valid computer configurations found!" >&2
            echo "" >&2
            echo "Please check your Infisical configuration format." >&2
            echo "Each secret should be in format: HOSTNAME=MAC:AD:DR:ES:S1:11" >&2
            exit 1
        fi
        
        echo "$result"
    else
        echo "Error: Failed to load configuration from Infisical!" >&2
        echo "" >&2
        echo "Please check:" >&2
        echo "  - Project ID: $PROJECT_ID" >&2
        echo "  - Environment: $ENVIRONMENT" >&2
        echo "  - Secret Path: $SECRET_PATH" >&2
        echo "  - Your Infisical authentication (try: infisical login)" >&2
        echo "" >&2
        exit 1
    fi
}

# Function to send WOL packet
send_wol() {
    local hostname=$1
    local mac=$2
    
    echo "Sending Wake-on-LAN packet to $hostname ($mac)..."
    
    # Check if wakeonlan command exists
    if command -v wakeonlan >/dev/null 2>&1; then
        wakeonlan $mac
    elif command -v etherwake >/dev/null 2>&1; then
        etherwake $mac
    elif command -v wol >/dev/null 2>&1; then
        wol $mac
    else
        echo "Error: No Wake-on-LAN tool found!"
        echo "Please install one of: wakeonlan, etherwake, or wol"
        echo ""
        echo "On macOS: brew install wakeonlan"
        echo "On Ubuntu/Debian: sudo apt install wakeonlan"
        echo "On CentOS/RHEL: sudo yum install net-tools"
        exit 1
    fi
    
    echo "Wake-on-LAN packet sent to $hostname"
}

# Function to display interactive menu
show_menu() {
    # Load computers from Infisical
    local computers_data
    computers_data=$(load_computers_from_infisical)
    
    # Check if we got valid data (the function exits on error, but just in case)
    if [[ -z "$computers_data" ]]; then
        exit 1
    fi
    
    declare -A computers
    eval "computers=($computers_data)"
    
    echo "Select a computer to wake up:"
    echo ""
    
    local i=1
    local hostnames=()
    
    for hostname in ${(k)computers}; do
        echo "$i) $hostname (${computers[$hostname]})"
        hostnames+=($hostname)
        ((i++))
    done
    
    echo ""
    echo -n "Enter your choice (1-$((i-1))): "
    read choice
    
    # Validate choice
    if [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#hostnames[@]} )); then
        selected_hostname=${hostnames[$choice]}
        echo ""
        send_wol $selected_hostname ${computers[$selected_hostname]}
    else
        echo "Invalid choice. Please enter a number between 1 and $((i-1))."
        exit 1
    fi
}

# Main script logic
if [[ $# -eq 0 ]]; then
    # No arguments - show interactive menu
    show_menu
elif [[ $# -eq 1 ]]; then
    # One argument - treat as hostname
    hostname=$1
    
    # Load computers from Infisical
    local computers_data
    computers_data=$(load_computers_from_infisical)
    
    # Check if we got valid data
    if [[ -z "$computers_data" ]]; then
        exit 1
    fi
    
    declare -A computers
    eval "computers=($computers_data)"
    
    if [[ -n ${computers[$hostname]} ]]; then
        send_wol $hostname ${computers[$hostname]}
    else
        echo "Error: Unknown hostname '$hostname'"
        echo ""
        echo "Available computers:"
        for host in ${(k)computers}; do
            echo "  - $host"
        done
        exit 1
    fi
else
    # Too many arguments
    # Load computers from Infisical to show available options
    local computers_data
    computers_data=$(load_computers_from_infisical)
    
    # Check if we got valid data
    if [[ -z "$computers_data" ]]; then
        exit 1
    fi
    
    declare -A computers
    eval "computers=($computers_data)"
    
    echo "Usage: $0 [hostname]"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive selection"
    echo "  $0 lhr1-hv-1         # Wake specific computer"
    echo ""
    echo "Configuration:"
    echo "  The script loads computer configurations from Infisical:"
    echo "    Project ID: $PROJECT_ID"
    echo "    Environment: $ENVIRONMENT"
    echo "    Secret Path: $SECRET_PATH"
    echo ""
    echo "  Override defaults using environment variables:"
    echo "    export INFISICAL_PROJECT_ID=your-project-id"
    echo "    export INFISICAL_ENVIRONMENT=your-environment"
    echo "    export INFISICAL_SECRET_PATH=your-secret-path"
    echo ""
    echo "Available computers:"
    for host in ${(k)computers}; do
        echo "  - $host"
    done
    exit 1
fi