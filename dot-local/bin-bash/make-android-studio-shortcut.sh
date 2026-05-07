#!/usr/bin/env bash
set -euo pipefail

# ✅ Input validation
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 /path/to/android-studio/bin/studio.sh /path/to/icon.png"
  exit 1
fi

ANDROID_EXEC="$1"
ICON_PATH="$2"

# 🔍 Validate paths
if [[ ! -x "$ANDROID_EXEC" ]]; then
  echo "❌ Executable not found or not executable: $ANDROID_EXEC"
  exit 1
fi

if [[ ! -f "$ICON_PATH" ]]; then
  echo "❌ Icon not found: $ICON_PATH"
  exit 1
fi

# 🏷️ Extract WM_CLASS from running Android Studio (fallback to known value if not detected)
echo "🕵️ Detecting StartupWMClass..."
DEFAULT_WMCLASS="jetbrains-studio"
DETECTED_WMCLASS=$(xprop -name "Android Studio" | grep "WM_CLASS" | awk -F\" '{print $4}' || echo "$DEFAULT_WMCLASS")

# 📁 Target desktop entry location
APP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APP_DIR/android-studio.desktop"

mkdir -p "$APP_DIR"

# 📝 Write the desktop entry
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=$ANDROID_EXEC %f
Icon=$ICON_PATH
Terminal=false
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=$DETECTED_WMCLASS
EOF

chmod +x "$DESKTOP_FILE"

# 🔄 Update desktop DB
update-desktop-database "$APP_DIR" &>/dev/null || true

echo "✅ Android Studio shortcut created at: $DESKTOP_FILE"
echo "📌 You should now be able to pin it to your system launcher."

