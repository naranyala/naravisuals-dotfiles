#!/usr/bin/env bash
#
# labwc-setup.sh — Minimal Labwc Wayland desktop installer + config generator
# Author: Fudzer (modular, audit-friendly scaffold)
# Updated: Adds seat group auto-create + seatd detection
#

set -euo pipefail

### --- CONFIG ---
PKGS_DEBIAN=(labwc waybar wofi swaybg swaylock xwayland seatd)
PKGS_ARCH=(labwc waybar wofi swaybg swaylock xorg-xwayland seatd)
CONFIG_DIR="${HOME}/.config/labwc"
THEME_NAME="Arc-Dark"
WALLPAPER_URL="https://raw.githubusercontent.com/labwc/labwc/main/data/wallpaper.jpg"

### --- FUNCTIONS ---

detect_pkg_manager() {
    if command -v apt >/dev/null; then
        echo "apt"
    elif command -v pacman >/dev/null; then
        echo "pacman"
    else
        echo "Unsupported package manager" >&2
        exit 1
    fi
}

install_packages() {
    local pm="$1"
    echo "[*] Installing packages for $pm..."
    case "$pm" in
        apt)
            sudo apt update
            sudo apt install -y "${PKGS_DEBIAN[@]}"
            ;;
        pacman)
            sudo pacman -Sy --needed "${PKGS_ARCH[@]}"
            ;;
    esac
}

generate_config() {
    echo "[*] Generating Labwc config in $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"

    # rc.xml — Openbox-style config
    cat > "$CONFIG_DIR/rc.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>${THEME_NAME}</name>
    <titleLayout>NLIMC</titleLayout>
  </theme>
  <keyboard>
    <keybind key="W-Return">
      <action name="Execute">
        <command>foot</command>
      </action>
    </keybind>
    <keybind key="W-d">
      <action name="Execute">
        <command>wofi --show drun</command>
      </action>
    </keybind>
    <keybind key="W-l">
      <action name="Execute">
        <command>swaylock</command>
      </action>
    </keybind>
  </keyboard>
  <mouse>
    <context name="Frame">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
    </context>
  </mouse>
</openbox_config>
EOF

    # autostart — run panel, wallpaper, etc.
    cat > "$CONFIG_DIR/autostart" <<EOF
#!/bin/sh
swaybg -i "\$HOME/.config/labwc/wallpaper.jpg" -m fill &
waybar &
EOF
    chmod +x "$CONFIG_DIR/autostart"

    # wallpaper
    curl -L "$WALLPAPER_URL" -o "$CONFIG_DIR/wallpaper.jpg"
}

enable_seatd() {
    echo "[*] Checking seat management..."
    if loginctl show-seat seat0 >/dev/null 2>&1; then
        echo "[=] Systemd-logind/elogind detected — seatd not required."
        return
    fi

    echo "[*] Ensuring 'seat' group exists..."
    sudo groupadd -f seat

    echo "[*] Adding user '$USER' to 'seat' group..."
    sudo usermod -aG seat "$USER"

    echo "[*] Enabling seatd service..."
    sudo systemctl enable --now seatd || {
        echo "[!] seatd service could not be enabled — check installation."
    }
}

print_post_install() {
    cat <<EOM

[+] Labwc setup complete!

To start Labwc from a TTY:
    dbus-run-session labwc

Config files are in:
    $CONFIG_DIR

You may need to log out and back in for group changes to take effect.
EOM
}

### --- MAIN ---
pm=$(detect_pkg_manager)
install_packages "$pm"
generate_config
enable_seatd
print_post_install

