#!/usr/bin/env bash
set -e

########################################
# Starship Installer & Customizer
########################################

USER_NAME=$(whoami)
CONFIG_DIR="/home/$USER_NAME/.config"
CONFIG_FILE="$CONFIG_DIR/starship.toml"

echo "🚀 Installing Starship prompt..."

# Install starship binary
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "✅ Starship already installed."
fi

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Write custom configuration
cat > "$CONFIG_FILE" <<'EOF'
# Starship Configuration File

# Prompt format
format = """
$username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character"""

# Custom symbols
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
style = "bold blue"

[git_branch]
symbol = "🌱 "
style = "bold purple"

[git_status]
style = "bold yellow"

[cmd_duration]
min_time = 2000
style = "bold italic red"
EOF

echo "✅ Config written to $CONFIG_FILE"

########################################
# Shell Integration
########################################

# Detect shell and append init line
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    bash)
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
        ;;
    zsh)
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        ;;
    fish)
        echo 'starship init fish | source' >> ~/.config/fish/config.fish
        ;;
    *)
        echo "⚠️ Unknown shell: $SHELL_NAME. Add init manually."
        ;;
esac

echo "🎉 Starship is installed and customized!"
echo "👉 Restart your terminal or run 'exec $SHELL' to apply changes."

