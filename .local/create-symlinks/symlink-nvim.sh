
#!/usr/bin/bash

USER=$(whoami)

backup="$target.bak"

DOT_PATH=""
target=""


set_linux_vars(){ 
	DOT_PATH="/run/media/naranyala/Data/projects-remote/naravisuals-dotfiles"

	target="$HOME/.config/nvim"
}

set_windows_vars(){ 
	# DOT_PATH="D:\projects-remote\modular-dotfiles"
	# DOT_PATH="D:\projects-remote\naravisuals-dotfiles"
	DOT_PATH="/d/projects-remote/naravisuals-dotfiles"

	target="/c/Users/Administrator/AppData/Local/nvim"
}


case "$(uname -s)" in
  Linux*)   set_linux_vars ;;
  CYGWIN*|MINGW*|MSYS*)  set_windows_vars ;;
  *)  echo "not supported: symlink-nvim.sh" ;;
esac


source="$DOT_PATH/.config/nvim"
# source="$DOT_PATH"

echo "DOT_PATH: $DOT_PATH"


# Check if target exists
if [ -e "$target" ]; then
    echo "📦 Backing up existing '$target' to '$backup'..."
    cp -a "$target" "$backup"
else
    echo "ℹ️ No existing '$target' found. Skipping backup."
fi

# Confirm before deletion
read -p "⚠️ This will delete '$target' and create a symlink. Proceed? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🗑 Removing '$target'..."
    rm -rf "$target"

    echo "🔗 Creating symlink: '$target' → '$source'"
    ln -s "$source" "$target"

    echo "✅ Done!"
else
    echo "❌ Operation cancelled."
fi

