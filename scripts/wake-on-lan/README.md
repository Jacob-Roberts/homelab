# Wake-on-LAN Script

A Zsh script for managing Wake-on-LAN (WOL) packets to wake up computers on your network. The script uses Infisical to securely store and retrieve computer MAC addresses.

## Features

- Interactive menu for selecting computers to wake up
- Direct hostname targeting via command line
- Secure configuration storage using Infisical
- Support for multiple WOL tools (`wakeonlan`, `etherwake`, `wol`)
- Environment variable overrides for flexible configuration

## Prerequisites

1. **Infisical CLI**: Install using the ansible playbook or manually
   ```bash
   # macOS
   brew install infisical
   
   # Linux (via ansible)
   ansible-playbook ansible/playbooks/install-infisical.yaml
   ```

2. **Wake-on-LAN tool**: One of the following
   ```bash
   # macOS
   brew install wakeonlan
   
   # Ubuntu/Debian
   sudo apt install wakeonlan
   
   # CentOS/RHEL
   sudo yum install net-tools
   ```

3. **Infisical Authentication**: Login to Infisical
   ```bash
   infisical login
   ```

## Configuration

### Infisical Setup

The script expects computer configurations to be stored in Infisical with the following default settings:

- **Project ID**: `f3732b81-3a85-430d-a547-43b85c363ad6`
- **Environment**: `prod`
- **Secret Path**: `/global/wake-on-lan`

### Adding Computers

In your Infisical project, add secrets in the following format:

```
LHR1-HV-1=00:1A:2B:3C:4D:5E
LHR1-STORAGE-1=00:1F:2E:3D:4C:5B
SGU1-NODE-1=AA:BB:CC:DD:EE:FF
```

Each secret key should be the hostname (case-insensitive) and the value should be the MAC address in standard format (with colons or hyphens).

### Environment Variables

Override default configuration using environment variables:

```bash
export INFISICAL_PROJECT_ID=your-project-id-uuid
export INFISICAL_ENVIRONMENT=your-environment
export INFISICAL_SECRET_PATH=your-secret-path
```

## Usage

### Interactive Mode

Run the script without arguments to see a menu of available computers:

```bash
./wake-on-lan.sh
```

Output:
```
Select a computer to wake up:

1) lhr1-hv-1 (00:1A:2B:3C:4D:5E)
2) lhr1-storage-1 (00:1F:2E:3D:4C:5B)
3) sgu1-node-1 (AA:BB:CC:DD:EE:FF)

Enter your choice (1-3): 
```

### Direct Hostname

Wake a specific computer by providing its hostname:

```bash
./wake-on-lan.sh lhr1-hv-1
```

### Help

Get usage information:

```bash
./wake-on-lan.sh --help
```

## Troubleshooting

### Authentication Issues

If you see authentication errors:

1. Login to Infisical: `infisical login`
2. Verify access to the project
3. Check project ID, environment, and path settings

### No Computers Found

If no computers are listed:

1. Verify Infisical configuration exists at the correct path
2. Check secret format (HOSTNAME=MAC:AD:DR:ES:S)
3. Ensure MAC addresses follow standard format

### WOL Tool Not Found

If you get "Wake-on-LAN tool not found" errors:

1. Install one of the supported tools (`wakeonlan`, `etherwake`, `wol`)
2. Ensure the tool is in your PATH

### Network Issues

For Wake-on-LAN to work:

1. Target computer must support WOL
2. WOL must be enabled in BIOS/UEFI
3. Network adapter must support WOL
4. Computer must be on the same network segment or properly configured for WOL forwarding

## Security

- MAC addresses are stored securely in Infisical
- No sensitive information is stored in environment variables or files
- Infisical provides audit logs for secret access