#!/usr/bin/env bash
# Ghostty setup script: smaller text size + respect previous tab directory

set -euo pipefail

CONFIG_DIR="$HOME/.config/ghostty"
CONFIG_FILE="$CONFIG_DIR/config"
BACKUP_FILE="$CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Backup existing config if present
if [[ -f "$CONFIG_FILE" ]]; then
  echo "Backing up existing config to $BACKUP_FILE"
  cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

# Apply desired settings
cat >"$CONFIG_FILE" <<'EOF'
# Ghostty configuration

# Smaller font size
font-size = 11

# Respect previous tab directory
# This makes new tabs inherit the working directory of the current tab
inherit-working-directory = true
EOF

echo "✅ Ghostty config updated at $CONFIG_FILE"
echo "   - Font size set to 11"
echo "   - New tabs inherit previous tab directory"
