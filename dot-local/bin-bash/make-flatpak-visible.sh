#!/usr/bin/env bash

# Directory to place global executables
TARGET_DIR="/usr/local/bin"

# Ensure script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

# Get list of installed Flatpak apps
flatpak list --app --columns=application | while read -r app_id; do
  # Extract a simple name from the app ID
  exec_name=$(basename "$app_id")

  # Create executable wrapper
  echo "#!/usr/bin/env bash
flatpak run $app_id \"\$@\"" > "$TARGET_DIR/$exec_name"

  chmod +x "$TARGET_DIR/$exec_name"
  echo "Created: $TARGET_DIR/$exec_name → flatpak run $app_id"
done

