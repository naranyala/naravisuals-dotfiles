#!/usr/bin/env bash
set -euo pipefail

# Configurable install directory
VCPKG_ROOT="$HOME/vcpkg"

echo ">>> Installing vcpkg into $VCPKG_ROOT"

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git not found in PATH"
  exit 1
fi

# Clone vcpkg if not already present
if [ ! -d "$VCPKG_ROOT" ]; then
  git clone --depth=1 https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
else
  echo ">>> vcpkg already cloned, pulling latest..."
  git -C "$VCPKG_ROOT" pull
fi

# Bootstrap vcpkg (builds the executable)
echo ">>> Bootstrapping vcpkg..."
"$VCPKG_ROOT/bootstrap-vcpkg.sh"

# Add vcpkg to PATH (temporary for this session)
export PATH="$VCPKG_ROOT:$PATH"

echo ">>> vcpkg installed successfully!"
echo ">>> Try: vcpkg version"

