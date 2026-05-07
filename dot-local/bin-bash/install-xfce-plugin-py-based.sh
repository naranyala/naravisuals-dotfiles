#!/usr/bin/env bash
#
# XFCE Panel Plugin Installer (Python-based)
# Usage: ./install_xfce_plugin.sh "PluginName" "/path/to/plugin.py"

set -e

# --- 1. Validate arguments ---
if [ $# -ne 2 ]; then
    echo "Usage: $0 <plugin_name> <plugin_file_path>"
    exit 1
fi

PLUGIN_NAME="$1"
PLUGIN_FILE="$2"

# Remove spaces from plugin name for internal use
PLUGIN_ID=$(echo "$PLUGIN_NAME" | tr '[:upper:] ' '[:lower:]-')

# --- 2. Check if file exists ---
if [ ! -f "$PLUGIN_FILE" ]; then
    echo "Error: Plugin file '$PLUGIN_FILE' not found."
    exit 1
fi

# --- 3. Define install paths ---
PLUGIN_DESKTOP_DIR="$HOME/.local/share/xfce4/panel/plugins"
PLUGIN_CODE_DIR="$HOME/.local/lib/xfce4/panel/plugins"

# --- 4. Create directories ---
mkdir -p "$PLUGIN_DESKTOP_DIR"
mkdir -p "$PLUGIN_CODE_DIR"

# --- 5. Copy plugin code ---
INSTALL_CODE_PATH="$PLUGIN_CODE_DIR/${PLUGIN_ID}.py"
cp "$PLUGIN_FILE" "$INSTALL_CODE_PATH"
chmod +x "$INSTALL_CODE_PATH"

# --- 6. Create .desktop file ---
DESKTOP_FILE="$PLUGIN_DESKTOP_DIR/${PLUGIN_ID}.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Xfce Panel]
Type=X-XFCE-PanelPlugin
Name=$PLUGIN_NAME
Comment=Custom XFCE Panel Plugin ($PLUGIN_NAME)
Icon=utilities-terminal
X-XFCE-Module=$PLUGIN_ID
X-XFCE-Internal=false
EOF

# --- 7. Restart XFCE panel ---
echo "Restarting XFCE panel..."
xfce4-panel -r

echo "✅ Plugin '$PLUGIN_NAME' installed!"
echo "➡ Now right-click the panel → Panel → Add New Items → find '$PLUGIN_NAME'."

