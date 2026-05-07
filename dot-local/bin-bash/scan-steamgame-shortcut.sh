#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# CONFIG
###############################################################################
DIRS=(
  "$HOME/Desktop"
  "$HOME/.local/share/applications"
  "/usr/share/applications"
)
URI_REGEX='steam://rungameid(/[0-9]+)?'

###############################################################################
# FLAGS
###############################################################################
DRY_RUN=1                         # default: safe mode
if [[ "${1:-}" == "--delete" ]]; then
  DRY_RUN=0
elif [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
elif [[ "${1:-}" ]]; then
  echo "Usage: $0 [--dry-run|--delete]" >&2
  exit 1
fi

###############################################################################
# UTILS
###############################################################################
cleanup(){ echo; echo "Interrupted." >&2; exit 5; }
trap cleanup INT TERM

red=$(tput setaf 1 2>/dev/null || true)
green=$(tput setaf 2 2>/dev/null || true)
yellow=$(tput setaf 3 2>/dev/null || true)
reset=$(tput sgr0 2>/dev/null || true)

###############################################################################
# 1. COLLECT MATCHES (content scan, case-insensitive)
###############################################################################
declare -a FILES=()
while IFS= read -r -d '' file; do
  exec_line=$(grep -m1 -iE '^Exec=' "$file" || true)
  [[ -z "$exec_line" ]] && continue
  grep -qiE 'steam://rungameid' <<<"$exec_line" || continue
  FILES+=("$file")
done < <(find "${DIRS[@]}" -type f -name '*.desktop' -print0 2>/dev/null)

((${#FILES[@]})) || { echo "No Steam game shortcuts found."; exit 2; }

###############################################################################
# 2. PRETTY PRINT
###############################################################################
printf "${yellow}%-60s %-30s %-12s %s${reset}\n" "FILE" "NAME" "GAMEID" "EXEC"
printf '%0.s-' {1..140}; echo

for file in "${FILES[@]}"; do
  exec_line=$(grep -m1 -iE '^Exec=' "$file")
  name_line=$(grep -m1 -iE '^Name=' "$file" || true)
  exec_val=${exec_line#Exec=}
  name_val=${name_line#Name=}
  gameids=$(grep -oE 'steam://rungameid/[0-9]+' <<<"$exec_val" \
            | sed 's|steam://rungameid/||g' | paste -sd';')
  printf "%-60s %-30s %-12s %s\n" "$file" "${name_val:--}" "${gameids:--}" "$exec_val"
done

printf '%0.s-' {1..140}; echo
echo "Total: ${#FILES[@]} shortcut(s)"

###############################################################################
# 3. DELETE MODE
###############################################################################
((DRY_RUN)) && { echo "(${yellow}dry-run${reset} – nothing deleted)"; exit 0; }

read -rp "Delete ALL ${#FILES[@]} shortcut(s)? [y/N] " ans
[[ $ans =~ ^[Yy]$ ]] || { echo "Deletion cancelled."; exit 3; }

failed=0
for f in "${FILES[@]}"; do
  if [[ -w $f ]]; then
    rm -f -- "$f" || ((failed++))
  else
    echo "${red}Permission denied:${reset} $f" >&2
    ((failed++))
  fi
done

if ((failed)); then
  echo "${red}${failed} deletion(s) failed.${reset}" >&2
  exit 4
fi

echo "${green}✓ Successfully deleted all ${#FILES[@]} shortcut(s).${reset}"
exit 0
