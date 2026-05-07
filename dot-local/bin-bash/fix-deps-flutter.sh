
#!/usr/bin/env bash
# install-packages.sh — Modular DNF installer with --skip-unavailable
# Usage: ./install-packages.sh [--dry-run]

set -euo pipefail

## 🧭 Config
PACKAGES=(
        curl
        git
        unzip
        xz
        zip
        mesa-libGLU
        glibc
        libstdc++
        clang++
        zlib
        bzip2
  cmake
  ninja-build
  clang
  gtk3-devel
  glibc-devel
  libblkid-devel
  xz-devel
  liblzma-devel
  pkgconf-pkg-config
  java-11-openjdk-devel
  git
  curl
  wget
  unzip
)

LOGFILE="/var/log/dnf-install-$(date +%F-%H%M%S).log"
DRY_RUN=false

## 🧪 Parse flags
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown option: $arg" && exit 1 ;;
  esac
done

## 🔍 Preflight
echo "[INFO] Starting package installation..."
echo "[INFO] Logging to: $LOGFILE"
echo "[INFO] Packages to install: ${PACKAGES[*]}"
echo "[INFO] Dry-run mode: $DRY_RUN"

## 🚀 Install
if $DRY_RUN; then
  echo "[DRY-RUN] Would run: sudo dnf install --skip-unavailable ${PACKAGES[*]}"
else
  sudo dnf install --skip-unavailable -y "${PACKAGES[@]}" | tee "$LOGFILE"
fi

echo "[DONE] Package installation complete."

