
#!/usr/bin/env bash
set -euo pipefail

# 🧰 Configuration
ARCH="$(uname -m)"
SWIFTLY_URL="https://download.swift.org/swiftly/linux/swiftly-${ARCH}.tar.gz"
SWIFTLY_TAR="swiftly-${ARCH}.tar.gz"
SWIFTLY_DIR="${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}"

# 📥 Download the Swiftly archive
echo "Downloading Swiftly for architecture: $ARCH"
curl -fsSL -o "$SWIFTLY_TAR" "$SWIFTLY_URL"

# 📦 Extract the archive
echo "Extracting archive..."
tar zxf "$SWIFTLY_TAR"

# ⚙️ Initialize Swiftly
echo "Initializing Swiftly..."
./swiftly init --quiet-shell-followup

# 🧪 Load environment
echo "Sourcing environment script..."
if [ -f "$SWIFTLY_DIR/env.sh" ]; then
  . "$SWIFTLY_DIR/env.sh"
else
  echo "❌ Failed to find env.sh in $SWIFTLY_DIR"
  exit 1
fi

# 🔄 Refresh shell cache
echo "Refreshing command cache..."
hash -r

echo "✅ Swiftly setup complete!"
