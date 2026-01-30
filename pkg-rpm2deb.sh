#!/bin/bash
# Convert .rpm package to .deb using alien
# Usage: ./rpm2deb.sh file.rpm

# Check if alien is installed
if ! command -v alien &> /dev/null; then
    echo "Error: alien is not installed. Install it first:"
    echo "  sudo apt install alien   # Debian/Ubuntu"
    echo "  sudo dnf install alien   # Fedora"
    exit 1
fi

# Check argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <package.rpm>"
    exit 1
fi

FILE="$1"

# Validate extension
if [[ "$FILE" != *.rpm ]]; then
    echo "Error: file must be a .rpm package"
    exit 1
fi

echo "Converting $FILE → DEB..."
sudo alien --to-deb "$FILE"

echo "✅ Conversion complete."

