
#!/bin/bash
set -e

echo "=== PyInstaller → .deb Builder ==="

# ===== Prompt with defaults =====
read -p "App name [myapp]: " APP_NAME
APP_NAME=${APP_NAME:-myapp}

read -p "Version [1.0.0]: " APP_VERSION
APP_VERSION=${APP_VERSION:-1.0.0}

read -p "Maintainer [Your Name <you@example.com>]: " MAINTAINER
MAINTAINER=${MAINTAINER:-"Your Name <you@example.com>"}

read -p "Description [My Python desktop app]: " DESCRIPTION
DESCRIPTION=${DESCRIPTION:-"My Python desktop app"}

read -p "Python entry file [main.py]: " PYTHON_ENTRY
PYTHON_ENTRY=${PYTHON_ENTRY:-main.py}

read -p "Icon path (optional, leave empty if none): " ICON_PATH

# ===== Verify entry file =====
if [[ ! -f "$PYTHON_ENTRY" ]]; then
    echo "ERROR: Python entry file '$PYTHON_ENTRY' not found!"
    exit 1
fi

# ===== Install pyinstaller if missing =====
if ! command -v pyinstaller &>/dev/null; then
    echo "PyInstaller not found. Installing..."
    pip install pyinstaller
fi

# ===== Clean old builds =====
echo "=== Cleaning previous builds ==="
rm -rf build dist "${APP_NAME}_${APP_VERSION}" *.spec

# ===== Build with PyInstaller =====
echo "=== Building executable ==="
pyinstaller --onefile --windowed "$PYTHON_ENTRY" --name "$APP_NAME"

# ===== Create Debian structure =====
echo "=== Creating Debian package structure ==="
mkdir -p "${APP_NAME}_${APP_VERSION}/DEBIAN"
mkdir -p "${APP_NAME}_${APP_VERSION}/usr/local/bin"
mkdir -p "${APP_NAME}_${APP_VERSION}/usr/share/applications"

# ===== Control file =====
cat > "${APP_NAME}_${APP_VERSION}/DEBIAN/control" <<EOF
Package: ${APP_NAME}
Version: ${APP_VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
EOF

# ===== Copy binary =====
cp "dist/${APP_NAME}" "${APP_NAME}_${APP_VERSION}/usr/local/bin/${APP_NAME}"
chmod 755 "${APP_NAME}_${APP_VERSION}/usr/local/bin/${APP_NAME}"

# ===== Desktop entry =====
cat > "${APP_NAME}_${APP_VERSION}/usr/share/applications/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Name=${APP_NAME}
Exec=${APP_NAME}
Icon=${APP_NAME}
Type=Application
Categories=Utility;
EOF

# ===== Optional icon =====
if [[ -n "$ICON_PATH" && -f "$ICON_PATH" ]]; then
    mkdir -p "${APP_NAME}_${APP_VERSION}/usr/share/icons/hicolor/256x256/apps"
    cp "$ICON_PATH" "${APP_NAME}_${APP_VERSION}/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
fi

# ===== Build .deb =====
echo "=== Building .deb package ==="
dpkg-deb --build "${APP_NAME}_${APP_VERSION}"

echo "=== Done! ==="
echo "Installer: ${APP_NAME}_${APP_VERSION}.deb"
echo "Install with:"
echo "  sudo dpkg -i ${APP_NAME}_${APP_VERSION}.deb"
