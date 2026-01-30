#!/bin/bash
# Script to expose Windows executables in Git Bash with progress indicator

WIN_DIRS=(
    "/c/Windows"
    "/c/Windows/System32"
    "/c/Windows/SysWOW64"
    "/c/Program Files"
    "/c/Program Files (x86)"
    "/c/Users/$(whoami)/AppData/Local/Microsoft/WinGet/Links/"
    "/c/ProgramData/chocolatey/bin"
    ""
)

TMP_FILE=$(mktemp)
mkdir -p ~/bin

echo "🔍 Scanning for executables..."

for dir in "${WIN_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "➡️ Searching in $dir ..."
        find "$dir" -maxdepth 2 -type f -iname "*.exe" >> "$TMP_FILE"
    fi
done

TOTAL=$(wc -l < "$TMP_FILE")
COUNT=0

echo "⚙️ Creating symlinks in ~/bin ..."
while IFS= read -r exe; do
    COUNT=$((COUNT+1))
    exe_name=$(basename "$exe")
    link_name="${exe_name%.exe}"
    ln -sf "$exe" "$HOME/bin/$link_name"

    # Simple progress indicator every 100 files
    if (( COUNT % 100 == 0 )); then
        echo "Processed $COUNT / $TOTAL executables..."
    fi
done < "$TMP_FILE"

rm "$TMP_FILE"

echo "✅ Done! $COUNT executables exposed."
echo "➡️ Restart Git Bash or run: source ~/.bashrc"
