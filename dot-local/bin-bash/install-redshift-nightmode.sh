#!/usr/bin/env bash

# 📦 Install Redshift and GeoClue (optional, in case you switch to auto)
install_redshift() {
    echo "🔧 Installing Redshift and GeoClue (optional)..."
    sudo apt update
    sudo apt install -y redshift redshift-gtk geoclue-2.0 || {
        echo "❌ Failed to install packages"; exit 1;
    }
}

# 📝 Set up manual configuration
setup_config() {
    echo "📝 Setting up Redshift manual configuration..."

    # Determine correct config path
    CONFIG_DIR="$HOME/.config/redshift"
    CONFIG_PATH="$CONFIG_DIR/redshift.conf"
    ALT_PATH="$HOME/.config/redshift.conf"

    # Create folder if needed
    mkdir -p "$CONFIG_DIR"

    # Config content
    CONFIG_CONTENT="[redshift]
temp-day=5500
temp-night=3500
fade=1
location-provider=manual

[manual]
lat=-7.6
lon=111.5
"

    # Write config
    echo "$CONFIG_CONTENT" > "$CONFIG_PATH"
    echo "✅ Manual config written to $CONFIG_PATH"

    # AppArmor workaround
    if grep -q "AppArmor" /sys/module/apparmor/parameters/enabled; then
        echo "⚠️ AppArmor detected — applying workaround..."
        mv "$CONFIG_PATH" "$ALT_PATH"
        echo "$CONFIG_CONTENT" > "$ALT_PATH"
        echo "✅ Config moved to $ALT_PATH"
    fi
}

# 🚀 Run Redshift as a background process
launch_redshift() {
    echo "🚀 Launching Redshift in background..."
    nohup redshift &>/dev/null &
    echo "✅ Redshift launched"
}

# 🔁 Main sequence
main() {
    install_redshift
    setup_config
    launch_redshift
    echo "🎉 All done. Your screen should shift to warm tones automatically!"
}

main

