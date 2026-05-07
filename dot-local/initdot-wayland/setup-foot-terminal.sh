#!/usr/bin/env bash
set -euo pipefail

# Paths
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/foot"
INI_FILE="$CONFIG_DIR/foot.ini"

# Theme: Nord
declare -A NORD_THEME=(
  [foreground]="d8dee9"
  [background]="2e3440"
  [regular0]="3b4252"
  [regular1]="bf616a"
  [regular2]="a3be8c"
  [regular3]="ebcb8b"
  [regular4]="81a1c1"
  [regular5]="b48ead"
  [regular6]="88c0d0"
  [regular7]="e5e9f0"
)

# Write foot.ini using theme array
write_config() {
  local -n theme=$1
  mkdir -p "$CONFIG_DIR"

  cat > "$INI_FILE" <<EOF
[main]
shell = ~/.nix-profile/bin/nix-shell
term = xterm-256color
font = CascadiaMono:size=12

[tweak]
font-monospace-warn=no

[colors]
foreground = ${theme[foreground]}
background = ${theme[background]}
regular0 = ${theme[regular0]}
regular1 = ${theme[regular1]}
regular2 = ${theme[regular2]}
regular3 = ${theme[regular3]}
regular4 = ${theme[regular4]}
regular5 = ${theme[regular5]}
regular6 = ${theme[regular6]}
regular7 = ${theme[regular7]}

[mouse]
hide-when-typing = yes

[cursor]
style = block
blink = yes

[scrollback]
lines = 10000
EOF
}

# Main flow
write_config NORD_THEME
echo "✅ foot.ini successfully written to: $INI_FILE"
