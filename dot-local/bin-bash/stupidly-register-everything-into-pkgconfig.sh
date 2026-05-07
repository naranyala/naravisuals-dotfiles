#!/usr/bin/env bash
# auto-register-local-bin.sh
# Register every binary in /usr/local/bin into pkg-config

set -euo pipefail

PC_DIR="/usr/local/lib/pkgconfig"
BIN_DIR="/usr/local/bin"

mkdir -p "$PC_DIR"

log() { echo "[+] $*"; }

for BIN in "$BIN_DIR"/*; do
  [[ -x "$BIN" ]] || continue
  PKG_NAME=$(basename "$BIN")
  PC_FILE="$PC_DIR/${PKG_NAME}.pc"

  cat <<EOF | sudo tee "$PC_FILE" >/dev/null
prefix=/usr/local
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin

Name: $PKG_NAME
Description: Auto-registered binary $PKG_NAME
Version: 1.0
Libs:
Cflags:
Requires:
EOF

  log "Registered $PKG_NAME -> $PC_FILE"
done

# Update PKG_CONFIG_PATH
if ! grep -q "$PC_DIR" ~/.bashrc; then
  echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$PC_DIR" >> ~/.bashrc
  log "Added $PC_DIR to PKG_CONFIG_PATH in ~/.bashrc"
fi

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PC_DIR"

log "Auto-registration complete. Total: $(ls -1 $BIN_DIR | wc -l) binaries."

