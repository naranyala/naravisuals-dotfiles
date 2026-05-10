#!/usr/bin/env bash
set -e

########################################
# GNOME Customization Script
# Installs Extension Manager + Dash to Panel (GitHub)
########################################

detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        echo "unsupported"
        exit 1
    fi
}

install_packages() {
    local PKG_MANAGER=$1
    shift
    local PACKAGES="$@"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        for pkg in $PACKAGES; do
            sudo apt install -y "$pkg" || echo "⚠️ Skipping missing package: $pkg"
        done
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        for pkg in $PACKAGES; do
            sudo dnf install -y "$pkg" || echo "⚠️ Skipping missing package: $pkg"
        done
    fi
}

install_extension_manager() {
    local PKG_MANAGER=$1
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_packages "$PKG_MANAGER" gnome-shell-extension-manager gnome-browser-connector
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        install_packages "$PKG_MANAGER" gnome-extensions-app gnome-browser-connector
    fi
}

install_dash_to_panel() {
    echo "📥 Cloning Dash to Panel (shallow)..."
    rm -rf /tmp/dash-to-panel
    git clone --depth=1 https://github.com/home-sweet-gnome/dash-to-panel.git /tmp/dash-to-panel
    cd /tmp/dash-to-panel

    echo "⚙️ Building and installing..."
    make install

    echo "🔌 Enabling Dash to Panel..."
    gnome-extensions enable dash-to-panel@jderose9.github.com || {
        echo "⚠️ Could not enable Dash to Panel automatically."
        echo "👉 Try enabling manually via Extension Manager."
    }

    echo "🚫 Disabling Dash to Dock (conflict)..."
    gnome-extensions disable dash-to-dock@micxgx.gmail.com || echo "ℹ️ Dash to Dock not installed."
}

main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "Using package manager: $PKG_MANAGER"

    echo "Installing dependencies..."
    install_packages "$PKG_MANAGER" git make wget unzip gnome-shell-extension-prefs

    echo "Installing Extension Manager..."
    install_extension_manager "$PKG_MANAGER"

    echo "Installing Dash to Panel..."
    install_dash_to_panel

    echo "✅ Setup complete!"
    echo "👉 Restart GNOME Shell (Alt+F2, type 'r') or reboot to activate extensions."
}

main "$@"

