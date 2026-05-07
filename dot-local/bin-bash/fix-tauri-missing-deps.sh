#!/usr/bin/env bash
# install_glib.sh - Install GLib development packages on Fedora and confirm installation

set -e  # Exit immediately if a command exits with a non-zero status

echo "🔄 Updating package list..."
sudo dnf -y update

echo "📦 Installing GLib runtime and development packages..."
sudo dnf -y install glib2 glib2-devel pkg-config

echo "✅ Checking installation with pkg-config..."

# Array of pkg-config modules to check
modules=("glib-2.0" "gobject-2.0" "gio-2.0")

for module in "${modules[@]}"; do
    if pkg-config --exists "$module"; then
        version=$(pkg-config --modversion "$module")
        echo "✔ $module found (version $version)"
    else
        echo "❌ $module NOT found"
        exit 1
    fi
done

echo "🎉 All required GLib packages are installed and confirmed!"

