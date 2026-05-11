#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Error occurred at line $LINENO"; exit 1' ERR

# === Detect package manager ===
if command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
else
    echo "❌ No supported package manager found (dnf or yum)."
    exit 1
fi
echo "✅ Using $PKG_MANAGER package manager..."

# === Install dependencies ===
echo "📦 Installing build dependencies..."
sudo $PKG_MANAGER install -y wget tar make gcc perl \
    perl-ExtUtils-MakeMaker perl-ExtUtils-Embed \
    rpm-build fakeroot || {
        echo "❌ Failed to install dependencies"
        exit 1
    }

# === Fetch latest Alien tarball ===
echo "🌐 Fetching latest Alien source..."
ALIEN_PAGE="http://http.debian.net/debian/pool/main/a/alien/"
ALIEN_TARBALL=$(wget -qO- "$ALIEN_PAGE" | \
    grep -oE 'alien_[0-9]+\.[0-9]+\.tar\.xz' | sort -V | tail -n1 || true)

if [[ -z "$ALIEN_TARBALL" ]]; then
    echo "❌ Could not detect latest Alien version from $ALIEN_PAGE"
    exit 1
fi

echo "📥 Latest version detected: $ALIEN_TARBALL"
wget -O "$ALIEN_TARBALL" "${ALIEN_PAGE}${ALIEN_TARBALL}"

# === Extract and build ===
tar -xJf "$ALIEN_TARBALL"
ALIEN_DIR=$(basename "$ALIEN_TARBALL" .tar.xz | sed 's/_/-/')
cd "$ALIEN_DIR"

echo "⚙️ Building Alien..."
perl Makefile.PL
make
sudo make install

# === Verify installation ===
if command -v alien >/dev/null 2>&1; then
    echo "🎉 Alien installed successfully at $(command -v alien)"
    echo "👉 Convert DEB → RPM: sudo alien -r package.deb"
    echo "👉 Convert RPM → DEB: sudo alien -d package.rpm"
else
    echo "❌ Alien installation failed."
    exit 1
fi

