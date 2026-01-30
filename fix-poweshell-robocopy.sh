#!/usr/bin/env bash

# Location of PowerShell profile (for PowerShell 7+)
PROFILE_PATH="$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"

# For Windows PowerShell (legacy), use:
# PROFILE_PATH="$HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"

# Ensure the directory exists
mkdir -p "$(dirname "$PROFILE_PATH")"

# Alias line to fix Scoop robocopy requirement
ALIAS_LINE="Set-Alias robocopy 'C:\\Windows\\System32\\Robocopy.exe'"

# If alias already exists, replace it; otherwise append
if grep -q "Set-Alias robocopy" "$PROFILE_PATH" 2>/dev/null; then
    sed -i "s|.*Set-Alias robocopy.*|$ALIAS_LINE|" "$PROFILE_PATH"
else
    echo "$ALIAS_LINE" >> "$PROFILE_PATH"
fi

echo "✅ PowerShell profile updated at $PROFILE_PATH"
echo "Restart PowerShell to apply the fix."

