#!/bin/zsh

# Wake-on-LAN script with interactive selection or direct hostname targeting

# Define computers and their MAC addresses
declare -A computers
computers=(
    ["lhr1-hv-1"]="00:1A:2B:3C:4D:5E"
    ["lhr1-storage-1"]="00:1F:2E:3D:4C:5B"
)

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
    echo "Usage: $0 [hostname]"
    echo ""
    echo "Examples:"
    echo "  $0                    # Interactive selection"
    echo "  $0 lhr1-hv-1         # Wake specific computer"
    echo ""
    echo "Available computers:"
    for host in ${(k)computers}; do
        echo "  - $host"
    done
    exit 1
fi