#!/usr/bin/env python3
"""
Docker Compose File Formatter

This script formats Docker Compose files with consistent, opinionated ordering.
Top-level sections are ordered as: name, networks, volumes, services.
"""

import argparse
import logging
import sys
from pathlib import Path
from typing import Dict, List, Optional, Union
from ruamel.yaml import YAML
from ruamel.yaml.representer import RoundTripRepresenter
from ruamel.yaml.constructor import RoundTripConstructor


class ComposeFormatter:
    """Handles formatting of Docker Compose files."""
    
    # Desired order for top-level keys
    TOP_LEVEL_ORDER = ["name", "networks", "volumes", "services"]
    
    # Desired order for service keys
    SERVICE_KEY_ORDER = [
        "image",
        "platform",
        "container_name", 
        "command",
        "read_only",
        "privileged",
        "user",
        "group_add",
        "security_opt",
        "sysctls",
        "cap_add",
        "cap_drop",
        "cgroup",
        "cgroup_parent",
        "depends_on",
        "restart",
        "healthcheck",
        "ports",
        "secrets",
        "environment",
        "networks", 
        "devices",
        "volumes",
        "tmpfs",
        "ulimits",
        # Everything else goes here
        "labels"  # Labels always last
    ]
    
    def __init__(self, indent: int = 2):
        """
        Initialize the formatter.
        
        Args:
            indent: Number of spaces for indentation
        """
        self.indent = indent
        self.yaml = YAML()
        self.yaml.preserve_quotes = False  # Force requoting based on our rules
        self.yaml.width = 1000  # Prevent line wrapping
        self.yaml.indent(mapping=indent, sequence=indent*2, offset=indent)  # Larger sequence indent for proper alignment
        self.yaml.map_indent = indent  
        self.yaml.sequence_indent = indent*2  # Double indent for sequence content
        self.yaml.sequence_dash_offset = indent  # Indent the dash, then content aligns properly
        
        # Configure to prefer double quotes when quotes are needed
        self.yaml.default_style = None  # Don't force quotes
        
        # Customize representer for better string handling
        def represent_str(dumper, data):
            # Only quote if the string contains characters that YAML would interpret specially
            # or if it would be ambiguous without quotes
            needs_quotes = (
                # Environment variable substitution
                data.startswith('${') or
                # YAML tags
                data.startswith('!') or
                # Contains YAML structural characters
                any(char in data for char in '{}[]') or
                # Contains quote characters 
                any(char in data for char in '"\'') or
                # Contains problematic characters for YAML parsing
                any(char in data for char in '|>&*!%@') or
                # Colon followed by space (would create a key-value pair)
                ': ' in data or
                # YAML reserved words (case insensitive)
                data.lower() in ('yes', 'no', 'true', 'false', 'on', 'off', 'null') or
                # Has leading/trailing whitespace
                data.strip() != data or
                # Empty string
                data == '' or
                # Starts with special characters that could be misinterpreted
                data.startswith(('#', '-', '?', ':', '@', '`', '|', '>', '<', '=', '+', '&'))
            )
            
            if needs_quotes:
                return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')
            return dumper.represent_scalar('tag:yaml.org,2002:str', data)
        
        self.yaml.representer.add_representer(str, represent_str)
        
    def format_file(self, file_path: Path) -> bool:
        """
        Format a single Docker Compose file.
        
        Args:
            file_path: Path to the compose file
            
        Returns:
            True if file was successfully formatted, False otherwise
        """
        try:
            logging.info(f"Processing: {file_path}")
            
            # Read and parse the file preserving comments
            with open(file_path, 'r', encoding='utf-8') as f:
                data = self.yaml.load(f)
            
            if not isinstance(data, dict):
                logging.warning(f"Skipping {file_path}: Not a valid compose file (root is not a dict)")
                return False
                
            # Reorder the top-level keys
            formatted_data = self._reorder_top_level(data)
            
            # Reorder service keys if services exist
            if 'services' in formatted_data and isinstance(formatted_data['services'], dict):
                for service_name, service_config in formatted_data['services'].items():
                    if isinstance(service_config, dict):
                        # Convert array syntax to map syntax for labels and environment
                        service_config = self._convert_arrays_to_maps(service_config)
                        # Reorder service keys
                        formatted_data['services'][service_name] = self._reorder_service_keys(service_config)
            
            # Write back to file with proper formatting
            with open(file_path, 'w', encoding='utf-8') as f:
                # Always start with YAML document separator
                f.write('---\n')
                self.yaml.dump(formatted_data, f)
                
            # Post-process to add blank lines between top-level sections
            self._add_blank_lines_between_sections(file_path)
                
            logging.info(f"Successfully formatted: {file_path}")
            return True
            
        except Exception as e:
            logging.error(f"Error processing {file_path}: {e}")
            return False
    
    def _convert_arrays_to_maps(self, service_config: Dict) -> Dict:
        """
        Convert array syntax to map syntax for labels and environment variables.
        Only converts when there are no comments (preserves commented arrays).
        
        Converts:
          labels:
            - "key=value"
        To:
          labels:
            key: value
            
        Args:
            service_config: Service configuration
            
        Returns:
            Service configuration with converted arrays
        """
        from ruamel.yaml.comments import CommentedMap, CommentedSeq
        
        # Keys that should be converted from array to map syntax
        convertible_keys = ['labels', 'environment']
        
        for key in convertible_keys:
            if key in service_config:
                value = service_config[key]
                
                # Check if it's an array/list
                if isinstance(value, (list, CommentedSeq)):
                    # Check if there are any comments on the array items
                    has_comments = False
                    if isinstance(value, CommentedSeq) and hasattr(value, 'ca'):
                        if hasattr(value.ca, 'items') and value.ca.items:
                            # Check if any items have comments
                            for item_comments in value.ca.items.values():
                                if item_comments and any(comment and comment.value.strip() for comment in item_comments if comment):
                                    has_comments = True
                                    break
                    
                    # Skip conversion if there are comments - preserve the original format
                    if has_comments:
                        continue
                    
                    converted_map = CommentedMap()
                    should_convert = True
                    
                    # Check if all items are key=value format
                    for item in value:
                        if isinstance(item, str) and '=' in item:
                            # Split on first = only (in case value contains =)
                            parts = item.split('=', 1)
                            if len(parts) == 2:
                                key_part = parts[0].strip()
                                value_part = parts[1].strip()
                                
                                # Remove quotes if they exist
                                if (key_part.startswith('"') and key_part.endswith('"')) or \
                                   (key_part.startswith("'") and key_part.endswith("'")):
                                    key_part = key_part[1:-1]
                                    
                                if (value_part.startswith('"') and value_part.endswith('"')) or \
                                   (value_part.startswith("'") and value_part.endswith("'")):
                                    value_part = value_part[1:-1]
                                
                                converted_map[key_part] = value_part
                            else:
                                should_convert = False
                                break
                        else:
                            should_convert = False
                            break
                    
                    # Only convert if all items were key=value format and no comments
                    if should_convert and converted_map:
                        service_config[key] = converted_map
        
        return service_config
        
    def _reorder_service_keys(self, service_config: Dict) -> Dict:
        """
        Reorder service keys according to the specified order.
        
        Args:
            service_config: Original service configuration
            
        Returns:
            Reordered service configuration
        """
        # Get current keys and their values
        items = list(service_config.items())
        
        # Clear the original dict while preserving its type and comments
        service_config.clear()
        
        # Add keys in the specified order if they exist (excluding labels)
        added_keys = set()
        for key in self.SERVICE_KEY_ORDER:
            if key != 'labels':  # Skip labels in the first pass
                for orig_key, value in items:
                    if orig_key == key:
                        service_config[key] = value
                        added_keys.add(key)
                        break
        
        # Add any remaining keys that weren't in our order list (except labels)
        for key, value in items:
            if key not in added_keys and key != 'labels':
                service_config[key] = value
                added_keys.add(key)
        
        # Add labels last if it exists
        for key, value in items:
            if key == 'labels':
                service_config[key] = value
                break
                
        return service_config
        
    def _reorder_top_level(self, data: Dict) -> Dict:
        """
        Reorder top-level keys according to the specified order.
        
        Args:
            data: Original compose data
            
        Returns:
            Reordered compose data
        """
        # Get current keys and their values
        items = list(data.items())
        
        # Clear the original dict while preserving its type and comments
        data.clear()
        
        # Add keys in the specified order if they exist
        added_keys = set()
        for key in self.TOP_LEVEL_ORDER:
            for orig_key, value in items:
                if orig_key == key:
                    data[key] = value
                    added_keys.add(key)
                    break
        
        # Add any remaining keys that weren't in our order list
        for key, value in items:
            if key not in added_keys:
                data[key] = value
                
        return data
    
    def _add_blank_lines_between_sections(self, file_path: Path):
        """
        Add blank lines between top-level sections.
        
        Args:
            file_path: Path to the file to process
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            new_lines = []
            found_first_key = False
            
            for i, line in enumerate(lines):
                stripped = line.strip()
                
                # Skip YAML document separator
                if stripped == '---':
                    new_lines.append(line)
                    continue
                
                # Check if this is a top-level key (starts at column 0, ends with :, not a comment)
                is_top_level_key = (
                    stripped and 
                    not line.startswith(' ') and 
                    not line.startswith('\t') and
                    stripped.endswith(':') and 
                    not stripped.startswith('#') and
                    ':' in stripped and stripped.split(':')[0].strip() in self.TOP_LEVEL_ORDER + ['version', 'include']  # Common top-level keys
                )
                
                # Add blank line before top-level sections (except the first one)
                if is_top_level_key and found_first_key:
                    # Only add blank line if the previous line isn't already blank
                    if new_lines and new_lines[-1].strip():
                        new_lines.append('\n')
                
                new_lines.append(line)
                
                if is_top_level_key:
                    found_first_key = True
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
                
        except Exception as e:
            logging.warning(f"Could not add blank lines to {file_path}: {e}")
    
    def format_directory(self, directory: Path, recursive: bool = True) -> Dict[str, int]:
        """
        Format all compose files in a directory.
        
        Args:
            directory: Directory to process
            recursive: Whether to process subdirectories
            
        Returns:
            Dictionary with counts of processed/successful files
        """
        stats = {"processed": 0, "successful": 0, "failed": 0}
        
        # Find compose files
        patterns = ["compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml"]
        
        for pattern in patterns:
            if recursive:
                files = directory.rglob(pattern)
            else:
                files = directory.glob(pattern)
                
            for file_path in files:
                stats["processed"] += 1
                if self.format_file(file_path):
                    stats["successful"] += 1
                else:
                    stats["failed"] += 1
        
        return stats


def setup_logging(verbose: bool = False):
    """Setup logging configuration."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(levelname)s: %(message)s',
        handlers=[logging.StreamHandler(sys.stdout)]
    )


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Format Docker Compose files with consistent ordering"
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Path to compose file or directory (default: current directory)"
    )
    parser.add_argument(
        "--recursive", "-r",
        action="store_true",
        help="Process directories recursively"
    )
    parser.add_argument(
        "--indent",
        type=int,
        default=2,
        help="Number of spaces for indentation (default: 2)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose logging"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be processed without making changes"
    )
    
    args = parser.parse_args()
    
    setup_logging(args.verbose)
    
    # Validate path
    path = Path(args.path)
    if not path.exists():
        logging.error(f"Path does not exist: {path}")
        sys.exit(1)
    
    # Create formatter
    formatter = ComposeFormatter(indent=args.indent)
    
    if args.dry_run:
        logging.info("DRY RUN MODE - No files will be modified")
    
    try:
        if path.is_file():
            # Process single file
            if not args.dry_run:
                success = formatter.format_file(path)
                if not success:
                    sys.exit(1)
            else:
                logging.info(f"Would process file: {path}")
        else:
            # Process directory
            if not args.dry_run:
                stats = formatter.format_directory(path, args.recursive)
                logging.info(f"Processed: {stats['processed']}, "
                           f"Successful: {stats['successful']}, "
                           f"Failed: {stats['failed']}")
                
                if stats['failed'] > 0:
                    sys.exit(1)
            else:
                # Dry run for directory
                patterns = ["compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml"]
                count = 0
                for pattern in patterns:
                    files = path.rglob(pattern) if args.recursive else path.glob(pattern)
                    for file_path in files:
                        logging.info(f"Would process: {file_path}")
                        count += 1
                logging.info(f"Would process {count} files total")
    
    except KeyboardInterrupt:
        logging.info("Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
