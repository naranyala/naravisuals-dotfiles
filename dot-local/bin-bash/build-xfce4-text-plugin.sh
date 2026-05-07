#!/bin/bash
PLUGIN_NAME="myplugin"
PLUGIN_DIR="$HOME/.local/share/xfce4/panel/plugins"
LIB_DIR="$HOME/.local/lib/xfce4/panel-plugins"

mkdir -p "$PLUGIN_DIR" "$LIB_DIR"

# Check what pkg-config files are available
echo "🔍 Checking available pkg-config files..."
find /usr/lib/*/pkgconfig /usr/share/pkgconfig -name "*xfce*panel*" 2>/dev/null | head -5

# Try different pkg-config names
PKG_CONFIG_NAME=""
for name in "libxfce4panel-2.0" "libxfce4panel-1.0" "xfce4-panel"; do
    if pkg-config --exists "$name" 2>/dev/null; then
        PKG_CONFIG_NAME="$name"
        echo "✅ Found: $name"
        break
    fi
done

if [ -z "$PKG_CONFIG_NAME" ]; then
    echo "❌ No libxfce4panel pkg-config found. Install with:"
    echo "sudo apt install libxfce4panel-2.0-dev xfce4-dev-tools"
    exit 1
fi

# Write desktop file
cat > "$PLUGIN_DIR/$PLUGIN_NAME.desktop" <<EOF
[Xfce Panel]
Type=X-XFCE-PanelPlugin
Name=My Simple Plugin
Comment=Displays two lines of text
Icon=utilities-terminal
X-XFCE-Module=$PLUGIN_NAME
X-XFCE-API=2.0
EOF

# Create temporary build directory
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# Write plugin source
cat > "$PLUGIN_NAME.c" <<EOF
#include <libxfce4panel/libxfce4panel.h>

static void plugin_construct(XfcePanelPlugin *plugin) {
    GtkWidget *vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2);
    gtk_box_pack_start(GTK_BOX(vbox), gtk_label_new("Line One"), FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(vbox), gtk_label_new("Line Two"), FALSE, FALSE, 0);
    gtk_widget_show_all(vbox);
    gtk_container_add(GTK_CONTAINER(plugin), vbox);
}

XFCE_PANEL_PLUGIN_REGISTER(plugin_construct);
EOF

# Build with explicit library linking
echo "🔧 Building plugin with $PKG_CONFIG_NAME..."
CFLAGS=$(pkg-config --cflags "$PKG_CONFIG_NAME" gtk+-3.0)
LIBS=$(pkg-config --libs "$PKG_CONFIG_NAME" gtk+-3.0)

gcc -Wall -fPIC -shared $CFLAGS "$PLUGIN_NAME.c" -o "lib$PLUGIN_NAME.so" $LIBS

if [ $? -eq 0 ]; then
    cp "lib$PLUGIN_NAME.so" "$LIB_DIR/"
    echo "✅ Plugin built and installed successfully"
    echo "🔁 Restarting panel..."
    xfce4-panel -r
else
    echo "❌ Build failed with $PKG_CONFIG_NAME"
    echo "Debug info:"
    echo "CFLAGS: $CFLAGS"
    echo "LIBS: $LIBS"
fi

cd /
rm -rf "$BUILD_DIR"
