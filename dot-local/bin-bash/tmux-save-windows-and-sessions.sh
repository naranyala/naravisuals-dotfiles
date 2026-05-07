#!/usr/bin/env bash
# save-tmux.sh
# Save tmux session layout, windows, panes, cwd, and commands.
# Also log details to ~/.tmux-sessions/sessions.log

session=${1:-$(tmux display-message -p '#S')}
outfile="$HOME/.tmux-sessions/${session}.tmux"
logfile="$HOME/.tmux-sessions/sessions.log"

mkdir -p "$HOME/.tmux-sessions"

{
  echo "tmux new-session -d -s $session -c \"$(tmux display-message -p '#{pane_current_path}')\""

  # Save windows
  tmux list-windows -t "$session" -F \
    'tmux new-window -t #{session_name} -n #{window_name} -c #{pane_current_path}'

  # Save panes with cwd + command
  tmux list-panes -t "$session" -F \
    'tmux split-window -t #{session_name}:#{window_index} -c #{pane_current_path} "#{pane_current_command}"'

  # Save layouts
  tmux list-windows -t "$session" -F \
    'tmux select-layout -t #{session_name}:#{window_index} #{window_layout}'

  # Save active window
  active=$(tmux display-message -p '#I')
  echo "tmux select-window -t ${session}:${active}"
} > "$outfile"

# --- Logging section ---
{
  echo "=== Saved session: $session ==="
  tmux list-windows -t "$session" -F 'Window #{window_index}: #{window_name}'
  tmux list-panes -t "$session" -F '  Pane #{pane_index} in #{window_name} [#{pane_current_path}] #{pane_current_command}'
  echo "Saved at: $(date)"
  echo
} >> "$logfile"

echo "✅ Saved session '$session' to $outfile"
echo "📝 Logged details to $logfile"

