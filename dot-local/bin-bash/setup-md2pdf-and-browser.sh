#!/usr/bin/env bash
# setup-md-to-pdf.sh
# One-shot installer for md-to-pdf with global headless Chromium on Debian/Ubuntu.
# Handles Ubuntu 23.10+ "No usable sandbox!" issue automatically.

set -Eeuo pipefail

echo "=== Updating system packages ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Installing base dependencies ==="
sudo apt install -y curl wget gnupg ca-certificates software-properties-common

echo "=== Installing Node.js (LTS) ==="
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "=== Installing md-to-pdf globally ==="
# Skip Puppeteer's bundled Chromium download
export PUPPETEER_SKIP_DOWNLOAD=true
sudo npm install -g md-to-pdf

echo "=== Installing Chromium browser ==="
if ! command -v chromium >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
  sudo apt install -y chromium || sudo apt install -y chromium-browser
fi

echo "=== Installing required shared libraries ==="
sudo apt install -y \
  libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 \
  libnss3 libcups2 libxss1 libxrandr2 libatk1.0-0 \
  libatk-bridge2.0-0 libpangocairo-1.0-0 libgtk-3-0

#   libnss3 libcups2 libxss1 libxrandr2 libasound2 libatk1.0-0 \
#
# echo "=== Installing fonts for better PDF rendering ==="
# sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk

echo "=== Detecting Chromium executable ==="
BROWSER_PATH="$(command -v chromium || command -v chromium-browser || true)"
if [ -z "$BROWSER_PATH" ]; then
  echo "ERROR: Chromium not found. Please install manually."
  exit 1
fi
echo "Found Chromium at: $BROWSER_PATH"

echo "=== Checking sandbox availability ==="
SANDBOX_PATH="$(dirname "$BROWSER_PATH")/chrome-sandbox"
USE_NO_SANDBOX=0
if [ -x "$SANDBOX_PATH" ]; then
  if [ "$(stat -c %a "$SANDBOX_PATH")" = "4755" ]; then
    echo "Sandbox helper is setuid — sandboxing available."
  else
    echo "Sandbox helper exists but not setuid — fixing permissions."
    sudo chown root:root "$SANDBOX_PATH"
    sudo chmod 4755 "$SANDBOX_PATH"
    echo "Sandbox fixed."
  fi
else
  echo "No usable chrome-sandbox found — will use --no-sandbox fallback."
  USE_NO_SANDBOX=1
fi

echo "=== Creating wrapper script: md2pdf ==="
sudo tee /usr/local/bin/md2pdf >/dev/null <<EOF
#!/usr/bin/env bash
# Wrapper for md-to-pdf using system Chromium with sandbox auto-detection
set -Eeuo pipefail
if [ \$# -lt 1 ]; then
  echo "Usage: md2pdf input.md [output.pdf]" >&2
  exit 2
fi

BROWSER="$BROWSER_PATH"
ARGS=""

# Auto-detect sandbox
if [ $USE_NO_SANDBOX -eq 1 ]; then
  ARGS="--no-sandbox"
fi

PUPPETEER_EXECUTABLE_PATH="\$BROWSER" \
PUPPETEER_ARGS="\$ARGS" \
md-to-pdf "\$@"
EOF
sudo chmod +x /usr/local/bin/md2pdf

echo "=== Installation complete! ==="
echo "Try it out with:"
echo "  md2pdf README.md README.pdf"

