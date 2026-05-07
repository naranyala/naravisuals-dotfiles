#!/usr/bin/env bash
# Fedora vcpkg setup script
# Installs vcpkg via dnf and configures VCPKG_ROOT

set -euo pipefail

echo "[INFO] Installing vcpkg from Fedora repository..."
sudo dnf install -y vcpkg

# --- Step 1: Detect vcpkg binary location ---
VCPKG_BIN="$(command -v vcpkg || true)"
if [ -z "$VCPKG_BIN" ]; then
    echo "[ERROR] vcpkg not found after install."
    exit 1
fi

# --- Step 2: Set root directory to binary path ---
VCPKG_DIR="$(dirname "$VCPKG_BIN")"
echo "[INFO] Detected vcpkg root: $VCPKG_DIR"

# --- Step 3: Configure VCPKG_ROOT ---
SHELL_RC="$HOME/.bashrc"
if ! grep -q "VCPKG_ROOT" "$SHELL_RC"; then
    echo "export VCPKG_ROOT=$VCPKG_DIR" >> "$SHELL_RC"
    echo "[INFO] Added VCPKG_ROOT to $SHELL_RC"
else
    sed -i "s|^export VCPKG_ROOT=.*|export VCPKG_ROOT=$VCPKG_DIR|" "$SHELL_RC"
    echo "[INFO] Updated existing VCPKG_ROOT in $SHELL_RC"
fi

# --- Step 4: Reload shell config ---
echo "[INFO] Reloading shell configuration..."
source "$SHELL_RC"

echo "[SUCCESS] vcpkg setup complete!"
echo "VCPKG_ROOT is set to: $VCPKG_ROOT"

