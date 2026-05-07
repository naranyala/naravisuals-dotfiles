#!/usr/bin/env bash

# Get focused window info
FOCUSED_WINDOW_JSON=$(niri msg -j focused-window)

if [ -z "$FOCUSED_WINDOW_JSON" ] || [ "$FOCUSED_WINDOW_JSON" == "null" ]; then
    echo '{"text": ""}'
    exit 0
fi

WORKSPACE_ID=$(echo "$FOCUSED_WINDOW_JSON" | jq '.workspace_id')
FOCUSED_ID=$(echo "$FOCUSED_WINDOW_JSON" | jq '.id')
APP_ID=$(echo "$FOCUSED_WINDOW_JSON" | jq -r '.app_id // .title')

# Simplify app_id if possible (e.g., org.kde.konsole -> Konsole)
CLEAN_APP_NAME=$(echo "$APP_ID" | awk -F. '{print $NF}' | sed 's/./\U&/')

# Get all windows in this workspace, sorted by their layout position
# We sort by the first element of pos_in_scrolling_layout
WINDOWS_IN_WORKSPACE=$(niri msg -j windows | jq ". | map(select(.workspace_id == $WORKSPACE_ID)) | sort_by(.layout.pos_in_scrolling_layout[0])")
TOTAL_WINDOWS=$(echo "$WINDOWS_IN_WORKSPACE" | jq 'length')

# Find the index of the focused window in the sorted list
INDEX=$(echo "$WINDOWS_IN_WORKSPACE" | jq "to_entries | map(select(.value.id == $FOCUSED_ID)) | .[0].key + 1")

# Format index and total as 1, 2, etc.
FORMATTED_INDEX=$(printf "%d" "$INDEX")
FORMATTED_TOTAL=$(printf "%d" "$TOTAL_WINDOWS")

# Output as JSON
echo "{\"text\": \" $FORMATTED_INDEX/$FORMATTED_TOTAL $CLEAN_APP_NAME\"}"
