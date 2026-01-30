
#!/usr/bin/env bash

# Bash script to install Scoop on Windows
# Works in Git Bash or WSL by invoking PowerShell

echo "Installing Scoop..."

# Run the PowerShell command to set execution policy and install Scoop
powershell -NoProfile -ExecutionPolicy RemoteSigned -Command \
  "iwr -useb get.scoop.sh | iex"

# Verify installation
if powershell -Command "Get-Command scoop -ErrorAction SilentlyContinue" > /dev/null; then
  echo "✅ Scoop installed successfully!"
else
  echo "❌ Scoop installation failed."
fi
