
#!/usr/bin/env bash
# fix-pkgconfig.sh
# Ensure pkg-config can find Homebrew packages on macOS (Intel or Apple Silicon)

set -euo pipefail

# Detect architecture
ARCH="$(uname -m)"

case "$ARCH" in
    arm64)
        BREW_PREFIX="/opt/homebrew"
        ;;
    x86_64)
        BREW_PREFIX="/usr/local"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

PKG_PATH="$BREW_PREFIX/lib/pkgconfig"

# Prepend to PKG_CONFIG_PATH if not already present
if [[ ":${PKG_CONFIG_PATH:-}:" != *":$PKG_PATH:"* ]]; then
    export PKG_CONFIG_PATH="$PKG_PATH:${PKG_CONFIG_PATH:-}"
    echo "PKG_CONFIG_PATH set to: $PKG_CONFIG_PATH"
else
    echo "PKG_CONFIG_PATH already includes $PKG_PATH"
fi
