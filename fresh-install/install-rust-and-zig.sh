#!/usr/bin/env bash
set -euo pipefail

trap 'echo "❌ Error occurred at line $LINENO"; exit 1' ERR

# -------------------------
# Rust installation (user base only)
# -------------------------
install_rust() {
    echo "📦 Installing Rust (user base)..."

    # Clean up any broken installs
    rm -rf "$HOME/.cargo" "$HOME/.rustup"

    # Run rustup installer in user space
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path

    # Explicitly install and set stable toolchain
    "$HOME/.cargo/bin/rustup" install stable
    "$HOME/.cargo/bin/rustup" default stable

    # Ensure PATH integration
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        bash) STARTUP_FILE="$HOME/.bashrc" ;;
        zsh)  STARTUP_FILE="$HOME/.zshrc" ;;
        *)    STARTUP_FILE="$HOME/.profile" ;;
    esac

    if ! grep -q 'source $HOME/.cargo/env' "$STARTUP_FILE"; then
        echo 'source $HOME/.cargo/env' >> "$STARTUP_FILE"
        echo "🔧 Added Rust environment to $STARTUP_FILE"
    fi

    # Load immediately
    source "$HOME/.cargo/env"

    rustc --version
    cargo --version
}

# -------------------------
# Zig installation (latest stable release, user base)
# -------------------------
install_zig() {
    if command -v zig >/dev/null 2>&1; then
        echo "ℹ️ Zig already installed: $(zig version)"
        return
    fi

    echo "📦 Installing Zig (latest stable release)..."
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64) ARCH="x86_64-linux" ;;
        aarch64) ARCH="aarch64-linux" ;;
        *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    ZIG_JSON=$(curl -s https://ziglang.org/download/index.json)

    ZIG_URL=$(echo "$ZIG_JSON" | jq -r '
        to_entries
        | map(select(.key | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")))
        | sort_by(.key | split(".") | map(tonumber))
        | last.value["'"$ARCH"'"].tarball
    ')

    if [ -z "$ZIG_URL" ] || [ "$ZIG_URL" = "null" ]; then
        echo "❌ Could not fetch Zig stable release URL for $ARCH"
        exit 1
    fi

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    echo "⬇️ Downloading Zig from $ZIG_URL..."
    curl -LO "$ZIG_URL"

    echo "📂 Extracting..."
    tar -xf "$(basename "$ZIG_URL")"

    DIR_NAME=$(basename "$ZIG_URL" .tar.xz)
    echo "🚀 Installing to $HOME/.local/zig..."
    rm -rf "$HOME/.local/zig"
    mv "$DIR_NAME" "$HOME/.local/zig"

    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/zig/zig" "$HOME/.local/bin/zig"

    cd -
    rm -rf "$TMP_DIR"

    # Add ~/.local/bin to PATH if missing
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    echo "✅ Zig installed successfully!"
    zig version
}

# -------------------------
# Main menu
# -------------------------
case "${1:-all}" in
    rust) install_rust ;;
    zig)  install_zig ;;
    all)  install_rust; install_zig ;;
    *)    echo "Usage: $0 [rust|zig|all]"; exit 1 ;;
esac

echo "🎉 Installation complete!"

