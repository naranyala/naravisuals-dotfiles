#!/bin/bash
APP_NAME="myapp"
WINEARCH="win64"  # Switched to win64 for better compatibility

WINEPREFIX="$HOME/$APP_NAME/prefix"
WINEPATH="$HOME/$APP_NAME"

# Remove existing prefix if corrupted
rm -rf "$WINEPREFIX"
mkdir -p "$WINEPREFIX"

export WINEPREFIX
export WINEARCH
export WINEPATH

echo "🍷 Creating fresh Wine prefix..."
wineboot --init

# Install Windows system components in order
echo "🔧 Installing Windows system libraries..."
winetricks -q --force win10
winetricks -q --force corefonts
winetricks -q --force vcrun2022
winetricks -q --force mfc42

# Register system DLLs manually
echo "🛠️ Registering system DLLs..."
wine regsvr32 /s "$WINEPREFIX/drive_c/windows/system32/kernel32.dll"
wine regsvr32 /s "$WINEPREFIX/drive_c/windows/system32/ntdll.dll"

# Set DLL overrides
echo "🎯 Configuring DLL overrides..."
wine regedit /s /dev/stdin <<EOF
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"kernel32"="native,builtin"
"ntdll"="native,builtin"
EOF

echo "✅ Wine setup complete. Test your application now."
