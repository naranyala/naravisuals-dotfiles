
#!/usr/bin/env bash
# restore-tmux.sh
# Restore tmux session from ~/.tmux-sessions/<session>.tmux

session=$1
file="$HOME/.tmux-sessions/${session}.tmux"

if [ -z "$session" ]; then
  echo "Usage: $0 <session-name>"
  exit 1
fi

if [ ! -f "$file" ]; then
  echo "❌ No saved session named '$session'"
  exit 1
fi

if tmux has-session -t "$session" 2>/dev/null; then
  echo "⚠️ Session '$session' already exists"
  exit 1
fi

bash "$file"
tmux switch-client -t "$session"

echo "✅ Restored session '$session'"
