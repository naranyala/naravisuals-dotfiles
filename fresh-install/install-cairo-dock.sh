#!/usr/bin/env bash
set -euo pipefail

# Konfigurasi
REPO="Cairo-Dock/cairo-dock-core"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

echo "==> Mengunduh dependensi yang diperlukan..."
sudo apt update
sudo apt install -y cmake git build-essential libglib2.0-dev libdbus-1-dev \
    libdbus-glib-1-dev libxml2-dev libpango1.0-dev libcairo2-dev \
    librsvg2-dev libgtk-3-dev libglu1-mesa-dev libx11-dev curl jq

echo "==> Mencari rilis terbaru dari $REPO..."
# Menggunakan 'jq' lebih aman untuk parsing JSON
LATEST_RELEASE=$(curl -sL "$API_URL")
TAG=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')

if [ "$TAG" == "null" ] || [ -z "$TAG" ]; then
  echo "Error: Gagal mendapatkan tag rilis!"
  exit 1
fi

ARCHIVE="cairo-dock-$TAG.tar.gz"
URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"

echo "==> Mengunduh: $TAG"
curl -L "$URL" -o "$ARCHIVE"

echo "==> Ekstraksi file..."
tar -xzf "$ARCHIVE"
cd "cairo-dock-core-$TAG"

echo "==> Memulai proses Build..."
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)

echo "==> Menginstal (memerlukan sudo)..."
sudo make install
sudo ldconfig

echo "==> Selesai! Cairo-Dock $TAG berhasil terinstal."

