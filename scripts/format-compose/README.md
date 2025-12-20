# Docker Compose Formatter

A Python script that formats Docker Compose files with consistent, opinionated ordering and structure.

## Features

- **Consistent top-level ordering**: Reorders sections as `name`, `networks`, `volumes`, `services`
- **Preserves YAML document separators**: Maintains `---` if present in the original file
- **Flexible processing**: Can handle single files or entire directory trees
- **Safe operation**: Includes dry-run mode to preview changes
- **Comprehensive logging**: Detailed output with optional verbose mode
- **Error handling**: Graceful handling of malformed files

## Installation

The script requires Python 3.12+ and PyYAML. Install dependencies with:

```bash
cd scripts/format-compose
pip install -e .
```

## Usage

### Basic Usage

```bash
# Format all compose files in current directory
python main.py

# Format a specific file
python main.py path/to/compose.yaml

# Format directory recursively
python main.py /path/to/directory --recursive

# Dry run to see what would be changed
python main.py --dry-run
```

### Command Line Options

- `path`: Path to compose file or directory (default: current directory)
- `--recursive`, `-r`: Process directories recursively
- `--indent`: Number of spaces for indentation (default: 2)
- `--verbose`, `-v`: Enable verbose logging
- `--dry-run`: Show what would be processed without making changes

### Examples

```bash
# Format the entire homelab directory recursively
python main.py /path/to/homelab --recursive

# Format with custom indentation
python main.py compose.yaml --indent 4

# Verbose dry run on current directory
python main.py --dry-run --verbose --recursive
```

## What It Does

The formatter will reorder your Docker Compose files to have this consistent structure:

```yaml
---
name: your-service

networks:
  frontend:
    external: true
  backend:
    driver: bridge

volumes:
  data:
    driver: local
  cache:
    external: true

services:
  web:
    image: docker.io/nginx
    # ... service configuration
```

### Key Ordering

1. **name** - The compose project name
2. **networks** - Network definitions
3. **volumes** - Volume definitions  
4. **services** - Service definitions

Any additional top-level keys will be preserved and placed after the standard ones.

## File Detection

The script automatically detects Docker Compose files with these names:
- `compose.yaml`
- `compose.yml`
- `docker-compose.yaml`
- `docker-compose.yml`

## Error Handling

- **Invalid YAML**: Files with syntax errors are skipped with error messages
- **Non-compose files**: Files that don't have a dictionary at the root are skipped
- **Permission errors**: Appropriate error messages for read/write issues
- **Missing files/directories**: Clear error messages for invalid paths

## Integration

You can run this script as part of your CI/CD pipeline or git hooks to ensure consistent formatting across your infrastructure-as-code repository.

### Git Hook Example

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
cd scripts/format-compose
python main.py ../../ --recursive
git add .
```

## Contributing

To extend the formatter:

1. **Custom ordering**: Modify `TOP_LEVEL_ORDER` in the `ComposeFormatter` class
2. **Service-level formatting**: Add methods to format within the services section
3. **Additional validation**: Add checks in the `format_file` method
