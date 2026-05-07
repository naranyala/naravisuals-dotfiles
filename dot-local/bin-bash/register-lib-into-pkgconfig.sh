#!/usr/bin/env bash
# register-pkg.sh
# Locate a package binary/lib and register it into pkg-config

set -euo pipefail

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

log() { echo -e "${GREEN}[+]${RESET} $*"; }
err() { echo -e "${RED}[-]${RESET} $*" >&2; }

if [[ $# -lt 1 ]]; then
  err "Usage: $0 <package-name> [version]"
  exit 1
fi

PKG_NAME="$1"
PKG_VERSION="${2:-1.0}"

# Step 1: Locate binary or library
BIN_PATH=$(command -v "$PKG_NAME" || true)
LIB_PATH=$(find /usr/lib /usr/local/lib -name "lib${PKG_NAME}.so*" 2>/dev/null | head -n1)

if [[ -z "$BIN_PATH" && -z "$LIB_PATH" ]]; then
  err "Could not locate $PKG_NAME binary or library."
  exit 1
fi

log "Located binary: ${BIN_PATH:-N/A}"
log "Located library: ${LIB_PATH:-N/A}"

# Step 2: Create pkg-config file
PC_DIR="/usr/local/lib/pkgconfig"
sudo mkdir -p "$PC_DIR"

PC_FILE="$PC_DIR/${PKG_NAME}.pc"

cat <<EOF | sudo tee "$PC_FILE" >/dev/null
prefix=/usr/local
exec_prefix=\${prefix}
libdir=$(dirname "${LIB_PATH:-/usr/local/lib}")
includedir=\${prefix}/include

Name: $PKG_NAME
Description: Auto-registered package $PKG_NAME
Version: $PKG_VERSION
Libs: -L\${libdir} -l$PKG_NAME
Cflags: -I\${includedir}
EOF

log "Registered $PKG_NAME into pkg-config: $PC_FILE"

# Step 3: Update PKG_CONFIG_PATH
if ! grep -q "PKG_CONFIG_PATH" ~/.bashrc; then
  echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$PC_DIR" >> ~/.bashrc
  log "Added $PC_DIR to PKG_CONFIG_PATH in ~/.bashrc"
fi

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PC_DIR"

# Step 4: Verify
if pkg-config --exists "$PKG_NAME"; then
  log "$PKG_NAME successfully registered. Version: $(pkg-config --modversion $PKG_NAME)"
else
  err "Registration failed."
fi

