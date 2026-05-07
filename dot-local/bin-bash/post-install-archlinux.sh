#!/usr/bin/env bash
# Arch Linux Post-Install Script (systemd or non-systemd)
# Focus: Low-level development environment
# Run as root

set -Eeuo pipefail

# ---------- PACKAGE LIST ----------
PACKAGES=(
    # Essentials
    base-devel
    linux-headers
    networkmanager
    vim
    git
    curl
    wget
    htop
    unzip
    zip
    ufw

    # Low-level development
    gcc
    clang
    lld
    make
    cmake
    ninja
    gdb
    valgrind
    perf
    nasm
    binutils
    strace
    ltrace
    pkgconf
    man-db
    man-pages
    texinfo
)
# -----------------------------------

# Require root
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Please run as root (sudo $0)"
    exit 1
fi

# Detect init system
detect_init() {
    if command -v systemctl >/dev/null 2>&1 && [[ "$(ps -p 1 -o comm=)" == "systemd" ]]; then
        echo "systemd"
    elif command -v rc-status >/dev/null 2>&1; then
        echo "openrc"
    elif command -v sv >/dev/null 2>&1; then
        echo "runit"
    else
        echo "unknown"
    fi
}

INIT_SYSTEM=$(detect_init)
echo "==> Detected init system: $INIT_SYSTEM"

echo "==> Updating system..."
pacman -Syu --noconfirm

echo "==> Installing packages..."
pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo "==> Enabling NetworkManager if supported..."
case "$INIT_SYSTEM" in
    systemd)
        systemctl enable --now NetworkManager || true
        ;;
    openrc)
        rc-update add NetworkManager default || true
        rc-service NetworkManager start || true
        ;;
    runit)
        ln -sf /etc/runit/sv/NetworkManager /var/service/ || true
        ;;
    *)
        echo "No known service manager found — skipping NetworkManager enable."
        ;;
esac

echo "==> Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw --force reset >/dev/null
    ufw default deny incoming
    ufw default allow outgoing
    ufw --force enable
    case "$INIT_SYSTEM" in
        systemd) systemctl enable ufw || true ;;
        openrc) rc-update add ufw default || true ;;
        runit) ln -sf /etc/runit/sv/ufw /var/service/ || true ;;
    esac
fi

echo "==> Enabling multilib repository..."
if [[ "$(uname -m)" == "x86_64" ]] && ! grep -q "^

\[multilib\]

" /etc/pacman.conf; then
    {
        echo ""
        echo "[multilib]"
        echo "Include = /etc/pacman.d/mirrorlist"
    } >> /etc/pacman.conf
    pacman -Syu --noconfirm
fi

echo "==> Setting pacman color and parallel downloads..."
sed -i 's/^#Color/Color/' /etc/pacman.conf
if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
fi

echo "==> Post-install complete! Low-level dev environment ready."

