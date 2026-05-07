#!/bin/bash

set -e  # Exit immediately on error

echo "🔧 Installing initial packages..."
sudo apt update
sudo apt install -y devscripts equivs

echo "📁 Cloning ungoogled-chromium-debian repository..."
if [ ! -d "ungoogled-chromium-debian" ]; then
    git clone https://github.com/ungoogled-software/ungoogled-chromium-debian.git
fi
cd ungoogled-chromium-debian

echo "🧩 Initializing submodules..."
git submodule update --init --recursive

echo "📦 Preparing the local source..."
debian/rules setup

echo "📥 Installing missing build dependencies..."
sudo mk-build-deps -i debian/control
rm ungoogled-chromium-build-deps_*

echo "🛠️ Building the package..."
dpkg-buildpackage -b -uc

echo "✅ Build complete!"

echo ""
echo "📚 Tutorial: Enabling Add-ons and Browsing Features in Ungoogled Chromium"
echo ""
echo "1️⃣ Install Chromium Web Store Extension:"
echo "   - Visit: https://github.com/NeverDecaf/chromium-web-store"
echo "   - Download the .crx file from the Releases section."
echo "   - Open Ungoogled Chromium and go to chrome://extensions"
echo "   - Enable 'Developer mode' (top right)."
echo "   - Drag and drop the .crx file into the extensions page."
echo "   - This allows installing extensions directly from the Chrome Web Store."

echo ""
echo "2️⃣ Enable Extension Installation Prompt:"
echo "   - Go to chrome://flags/#extension-mime-request-handling"
echo "   - Set it to 'Always prompt for install'."

echo ""
echo "3️⃣ Re-enable Disabled Browsing Features:"
echo "   - Some features like WebGL, Safe Browsing, and DRM are disabled by default."
echo "   - To re-enable them, use command-line flags or config files:"
echo "     Example: launch Chromium with:"
echo "     chromium --enable-features=WebGL,WidevineCdm --disable-features=NoSearch"
echo "   - You can also edit ~/.config/chromium-flags.conf to persist these settings."

echo ""
echo "4️⃣ DRM Content (Netflix, Prime Video, etc.):"
echo "   - Download Widevine plugin manually from: https://dl.google.com/widevine-cdm/"
echo "   - Extract and load it as an unpacked extension."
echo "   - Note: DRM support may be limited depending on Chromium version."

echo ""
echo "🎉 You're now ready to enjoy a more functional and private Ungoogled Chromium experience!"

