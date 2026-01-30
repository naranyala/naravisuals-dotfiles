#!/bin/bash
# Convert .deb package to .rpm using alien
# Usage: ./deb2rpm.sh file.deb

# Check if alien is installed
if ! command -v alien &> /dev/null; then
    echo "Error: alien is not installed. Install it first:"
    echo "  sudo apt install alien   # Debian/Ubuntu"
    echo "  sudo dnf install alien   # Fedora"
    exit 1
fi

# Check argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <package.deb>"
    exit 1
fi

FILE="$1"

# Validate extension
if [[ "$FILE" != *.deb ]]; then
    echo "Error: file must be a .deb package"
    exit 1
fi

echo "Converting $FILE → RPM..."
sudo alien --to-rpm "$FILE"

echo "✅ Conversion complete."

