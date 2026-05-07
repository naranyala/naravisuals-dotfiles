#!/usr/bin/env bash
set -euo pipefail

# ✋ Require all arguments
if [[ $# -lt 5 ]]; then
  echo "Usage:"
  echo "  $0 <AppName> <ExecCommand> <IconSourcePath> <WorkingDir> <Comment>"
  echo ""
  echo "Example:"
  echo "  $0 \"TLauncher\" \"/usr/games/tlauncher/run.sh\" \"~/Downloads/tlauncher.png\" \"/usr/games/tlauncher\" \"Run client for the games\""
  exit 1
fi

APP_NAME="$1"
EXEC_COMMAND="$2"
ICON_SOURCE="$3"
APP_PATH="$4"
APP_COMMENT="$5"

# 📁 Paths
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
ICON_NAME="${APP_NAME// /-}.png"
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME// /-}.desktop"

mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# 🖼️ Copy icon to standard location
ICON_SOURCE_EXPANDED=$(realpath "$ICON_SOURCE")
cp -f "$ICON_SOURCE_EXPANDED" "$ICON_DIR/$ICON_NAME"

# 🔄 Update icon cache
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true

# 🕵️ Detect StartupWMClass (optional)
echo "🔍 Attempting to detect StartupWMClass..."
WMCLASS=$(xprop -name "$APP_NAME" | grep WM_CLASS | awk -F\" '{print $4}' || true)
if [[ -z "$WMCLASS" ]]; then
  WMCLASS="${APP_NAME// /-}"
  echo "⚠️ Could not detect WM_CLASS. Using fallback: $WMCLASS"
else
  echo "✅ Detected WM_CLASS: $WMCLASS"
fi

# 📝 Write .desktop file
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=$APP_COMMENT
Exec=$EXEC_COMMAND
Icon=${APP_NAME// /-}
Terminal=false
Path=$APP_PATH
StartupNotify=true
StartupWMClass=$WMCLASS
EOF

chmod +x "$DESKTOP_FILE"

# 🧠 Trust and validate
gio set "$DESKTOP_FILE" metadata::trusted true || true
desktop-file-validate "$DESKTOP_FILE" || echo "⚠️ Validation warning (non-fatal)"

# 🔄 Refresh desktop DB
update-desktop-database "$DESKTOP_DIR" &>/dev/null || true

echo "✅ Launcher created: $DESKTOP_FILE"
echo "📌 You can now pin '$APP_NAME' in your system launcher!"

# EXAMPLE
#
./create_launcher.sh "TLauncher" \
"/usr/games/tlauncher/lib/jvm/jre/bin/java -Dfile.encoding=UTF8 -jar /usr/games/tlauncher/starter-core.jar" \
"/usr/games/tlauncher/tlauncher.png" \
"/usr/games/tlauncher" \
"Run client for the games"
#
