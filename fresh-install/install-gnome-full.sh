#!/usr/bin/env bash
set -e

########################################
# Utility Functions
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

run_install() {
    local PKG_MANAGER=$1
    shift
    local PACKAGES="$@"

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update
        for pkg in $PACKAGES; do
            sudo apt install -y "$pkg" || echo "⚠️ Skipping not found package: $pkg"
        done
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y --skip-broken $PACKAGES
    fi
}

########################################
# GNOME Installation
########################################
install_gnome() {
    local PKG_MANAGER=$1

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        run_install "$PKG_MANAGER" \
            gnome-shell \
            gnome-session \
            gnome-control-center \
            gnome-terminal \
            gnome-system-monitor \
            gnome-disk-utility \
            gnome-tweaks \
            gnome-calculator \
            gnome-text-editor \
            nautilus \
            evince \
            eog \
            file-roller \
            seahorse \
            ubuntu-gnome-desktop

    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        run_install "$PKG_MANAGER" \
            gnome-shell \
            gnome-session \
            gnome-control-center \
            gnome-terminal \
            gnome-system-monitor \
            gnome-disk-utility \
            gnome-tweaks \
            gnome-calculator \
            gedit \
            nautilus \
            evince \
            eog \
            file-roller \
            seahorse
    fi
}

########################################
# Login Manager Installation
########################################
install_login_manager() {
    local PKG_MANAGER=$1

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        run_install "$PKG_MANAGER" gdm3
        sudo systemctl enable gdm
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        run_install "$PKG_MANAGER" gdm
        # Disable SDDM if it exists
        sudo systemctl disable sddm || true
        # Force-enable GDM to overwrite symlink
        sudo systemctl enable gdm --force
    fi
}

########################################
# Extras (Optional)
########################################
install_extras() {
    local PKG_MANAGER=$1

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        run_install "$PKG_MANAGER" \
            fonts-dejavu \
            fonts-noto \
            gnome-software \
            gnome-shell-extensions
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        run_install "$PKG_MANAGER" \
            dejavu-sans-fonts \
            google-noto-sans-fonts \
            gnome-software \
            gnome-shell-extension-apps-menu \
            gnome-shell-extension-common
    fi
}

########################################
# Main Script
########################################
main() {
    PKG_MANAGER=$(detect_package_manager)
    echo "Detected package manager: $PKG_MANAGER"

    echo "Installing GNOME Desktop..."
    install_gnome "$PKG_MANAGER"

    echo "Installing Login Manager..."
    install_login_manager "$PKG_MANAGER"

    echo "Installing Extras..."
    install_extras "$PKG_MANAGER"

    echo "✅ Full GNOME Desktop Environment installation complete!"
    echo "👉 Run: sudo systemctl set-default graphical.target"
    echo "👉 Reboot your system to start GNOME."
}

main "$@"
