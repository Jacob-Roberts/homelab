#!/bin/bash

# Configuration
SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME/.config/containers/systemd"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

echo "🚀 Deploying Quadlets from $SOURCE_DIR to $TARGET_DIR..."

# Find all relevant Podman files in the repo
# This finds .container, .volume, .network, and .pod files
files=$(find "$SOURCE_DIR" -type f \( -name "*.container" -o -name "*.volume" -o -name "*.network" -o -name "*.pod" \))

for file in $files; do
    filename=$(basename "$file")
    echo "🔗 Linking $filename..."
    # Force creation of symlink (-f)
    ln -sf "$file" "$TARGET_DIR/$filename"
done

# Reload systemd to recognize new or changed Quadlets
echo "🔄 Reloading systemd daemon..."
systemctl --user daemon-reload

echo "✅ Done! You can now start services with 'systemctl --user start <name>'"