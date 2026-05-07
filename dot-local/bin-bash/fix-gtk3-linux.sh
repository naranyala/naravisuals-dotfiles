
#!/usr/bin/env bash

set -e

echo "🔍 Detecting system..."

# Detect and install GTK3 dev package
if command -v apt-get &>/dev/null; then
    echo "📦 Detected Debian/Ubuntu. Installing libgtk-3-dev..."
    sudo apt update
    sudo apt install -y libgtk-3-dev pkg-config
elif command -v pacman &>/dev/null; then
    echo "📦 Detected Arch/Manjaro. Installing gtk3..."
    sudo pacman -Sy --noconfirm gtk3 pkgconf
elif command -v dnf &>/dev/null; then
    echo "📦 Detected Fedora. Installing gtk3-devel..."
    sudo dnf install -y gtk3-devel pkgconf
else
    echo "❌ Unsupported distro. Please install GTK3 development headers manually."
    exit 1
fi

# Ensure PKG_CONFIG_PATH includes correct directory
GTK_PC_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig"
if [ -d "$GTK_PC_PATH" ]; then
    echo "🔧 Setting PKG_CONFIG_PATH for GTK3..."
    export PKG_CONFIG_PATH="$GTK_PC_PATH"
    echo "export PKG_CONFIG_PATH=$GTK_PC_PATH" >> ~/.bashrc
    echo "✅ PKG_CONFIG_PATH patched. You may need to restart your terminal."
else
    echo "⚠️ GTK3 .pc directory not found: $GTK_PC_PATH"
    echo "   Try: find /usr -name gtk+-3.0.pc to locate manually."
fi

echo "✅ Setup complete. Try rebuilding your Go project now."
