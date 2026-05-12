#!/bin/bash

set -e

REPO_URL="https://github.com/ggerganov/llama.cpp.git"
INSTALL_DIR="/opt/llama.cpp"
BIN_DIR="/usr/local/bin"

show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -r, --reinstall  Remove existing installation and reinstall"
    echo
    echo "Examples:"
    echo "  llama-server --model ./models/7B/ggml-model.bin --port 8080"
    echo "  llama-tts --model ./models/tts/ggml-voice.bin --text 'Hello world!'"
    echo "  llama-bench --model ./models/7B/ggml-model.bin"
}

REINSTALL=false
for arg in "$@"; do
    case $arg in
        -h|--help) show_help; exit 0 ;;
        -r|--reinstall) REINSTALL=true ;;
        *) echo "Unknown option: $arg"; show_help; exit 1 ;;
    esac
done

echo "Checking dependencies..."
for dep in git cmake g++ make; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo "❌ Missing dependency: $dep"
        echo "Please install it via apt (Debian/Ubuntu) or dnf (Fedora/RHEL)."
        exit 1
    fi
done

if [ "$REINSTALL" = true ]; then
    echo "Reinstall requested. Removing old installation..."
    sudo rm -rf "$INSTALL_DIR"
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️ llama.cpp already exists at $INSTALL_DIR. Use --reinstall to overwrite."
    exit 1
fi

echo "Cloning llama.cpp repository..."
sudo git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" || { echo "❌ Failed to clone repository"; exit 1; }

echo "Building all llama.cpp binaries with CMake..."
cd "$INSTALL_DIR"
mkdir -p build && cd build
cmake ..
cmake --build . -j$(nproc)

echo "Locating built binaries..."
BINARIES=$(find "$INSTALL_DIR/build/bin" -type f -executable)

if [ -z "$BINARIES" ]; then
    echo "❌ No binaries found after build."
    exit 1
fi

echo "Registering binaries globally..."
for bin in $BINARIES; do
    name=$(basename "$bin")
    sudo ln -sf "$bin" "$BIN_DIR/$name"
    echo "Linked $name → $BIN_DIR/$name"
done

echo "✅ Installation complete!"
echo "Available commands:"
for bin in $BINARIES; do
    echo "  $(basename "$bin")"
done
show_help

