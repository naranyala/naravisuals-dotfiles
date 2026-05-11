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
echo "📦 Installing dependencies..."
sudo $PKG_MANAGER install -y git ruby ruby-devel gcc make rpm-build dpkg || {
    echo "❌ Failed to install dependencies"
    exit 1
}

# === Clone FPM source ===
echo "🌐 Cloning FPM source..."
if [[ ! -d fpm ]]; then
    git clone https://github.com/jordansissel/fpm.git
fi
cd fpm

# === Install FPM via RubyGems ===
echo "⚙️ Installing FPM..."
sudo gem install fpm || {
    echo "❌ Failed to install FPM"
    exit 1
}

# === Wrapper function ===
cat << 'EOF' | sudo tee /usr/local/bin/fpm-convert > /dev/null
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "❌ Missing arguments!"
    echo "Usage: fpm-convert <input_pkg> <target_format>"
    echo "Example: fpm-convert package.deb rpm"
    exit 1
fi

INPUT="$1"
TARGET="$2"

echo "🔄 Converting $INPUT to $TARGET..."
fpm -s $([[ "$INPUT" == *.deb ]] && echo "deb" || echo "rpm") -t "$TARGET" "$INPUT"
EOF

sudo chmod +x /usr/local/bin/fpm-convert

echo "🎉 FPM installed successfully!"
echo "👉 Usage example:"
echo "   fpm-convert package.deb rpm"
echo "   fpm-convert package.rpm deb"

