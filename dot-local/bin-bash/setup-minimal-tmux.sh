#!/usr/bin/env bash

CONFIG_FILE="$HOME/.tmux.conf"

generate_config() {
cat <<'EOF' > "$CONFIG_FILE"
# Minimal yet practical tmux config

# --- Basics ---
set -g base-index 1
setw -g pane-base-index 1

set-option -g renumber-windows on
set-option -g mouse on


# Change prefix to SPACE key
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

set-option -g status-position top

# --- Window bar formatting ---
# Inactive windows: just index + name, with subtle color
# setw -g window-status-format "#[fg=grey]#I:#W"

# Active window: highlighted, bold, inside [brackets]
# setw -g window-status-current-format "#[bold,fg=yellow][#I:#W]"

# Left side: all window listings
#set -g status-left "#[fg=green]#S #[fg=default]"

# Right side: user@host + uptime
set -g status-right "#[fg=cyan]#(whoami)@#H #[fg=yellow]#(uptime -p)"
set -g status-right-length 50

# Give windows room on the left
set -g status-left-length 200
set -g status-justify left

# --- Status bar look ---
set -g status-bg black
set -g status-fg white
set -g status-interval 5

bind-key - split-window -v -c "#{pane_current_path}"
bind-key | split-window -h -c "#{pane_current_path}"


bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Reload config binding
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
EOF
echo "Config written to $CONFIG_FILE"
}

show_manual() {
    echo "=== Default tmux key bindings ==="
    tmux list-keys
    echo
    echo "=== All tmux commands ==="
    tmux list-commands
}

case "$1" in
    --setup)
        generate_config
        ;;
    --manual|"")
        show_manual
        ;;
    *)
        echo "Unknown option: $1"
        echo "Try: $0 --manual or $0 --setup"
        exit 1
        ;;
esac

