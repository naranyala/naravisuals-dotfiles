
#!/bin/bash

# Function to add a path to PKG_CONFIG_PATH if it exists and isn't already included
add_to_pkg_config_path() {
    local path="$1"
    if [ -d "$path" ] && [[ ":$PKG_CONFIG_PATH:" != *":$path:"* ]]; then
        PKG_CONFIG_PATH="$path:$PKG_CONFIG_PATH"
    fi
}

# Common paths for .pc files
common_paths=(
    "/usr/lib/pkgconfig"
    "/usr/local/lib/pkgconfig"
    "/usr/share/pkgconfig"
    "/opt/*/lib/pkgconfig"
    "$HOME/.local/lib/pkgconfig"
)

# Search for .pc files in common paths
for path in "${common_paths[@]}"; do
    add_to_pkg_config_path "$path"
done

# Export the updated PKG_CONFIG_PATH
export PKG_CONFIG_PATH

# Update shell configuration file (e.g., ~/.bashrc)
shell_config="$HOME/.bashrc"
if ! grep -q "PKG_CONFIG_PATH" "$shell_config"; then
    echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> "$shell_config"
    echo "Updated $shell_config with PKG_CONFIG_PATH."
else
    echo "PKG_CONFIG_PATH is already set in $shell_config."
fi

# Print the updated PKG_CONFIG_PATH
echo "Updated PKG_CONFIG_PATH:"
echo "$PKG_CONFIG_PATH"
