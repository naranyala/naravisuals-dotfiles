#!/usr/bin/env bash
set -euo pipefail

# ---------- config ----------
DIRS=(
  "$HOME/Desktop"
  "$HOME/.local/share/applications"
  "/usr/share/applications"
)
CENTRAL_DIR="/usr/share/applications"

# ---------- flags ----------
MOVE=0
[[ "${1:-}" == "--move" ]] && MOVE=1

# ---------- utils ----------
cleanup(){ echo; echo "Interrupted." >&2; exit 5; }
trap cleanup INT TERM

green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
red=$(tput setaf 1 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)

# ---------- collect ----------
while IFS= read -r -d '' file; do
    FILES+=("$file")
done < <(find "${DIRS[@]}" -type f -name '*.desktop' -print0 2>/dev/null)

((${#FILES[@]})) || { echo "No .desktop shortcuts found."; exit 2; }

# ---------- list ----------
echo "Found ${#FILES[@]} .desktop file(s):"
printf '%s\n' "${FILES[@]}"
echo "Total: ${#FILES[@]}"
echo

# ---------- leave if only listing ----------
((MOVE==0)) && exit 0

# ---------- move ----------
mkdir -p "$CENTRAL_DIR"
echo "Central folder: $CENTRAL_DIR"
read -rp "Move ALL ${#FILES[@]} shortcut(s)? [y/N] " ans
[[ $ans =~ ^[Yy]$ ]] || { echo "Move cancelled."; exit 3; }

failed=0
for src in "${FILES[@]}"; do
  bn=$(basename "$src")
  dst="$CENTRAL_DIR/$bn"
  counter=1
  while [[ -e "$dst" ]]; do               # auto-rename on clash
    dst="$CENTRAL_DIR/${bn%.*}.$counter.${bn##*.}"
    ((counter++))
  done
  mv -- "$src" "$dst" 2>/dev/null || ((failed++))
done

if ((failed)); then
  echo "${red}$failed move(s) failed.${reset}" >&2
  exit 4
fi

echo "${green}✓ Moved all ${#FILES[@]} shortcut(s).${reset}"
exit 0
