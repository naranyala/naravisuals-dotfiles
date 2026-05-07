#!/usr/bin/env bash

# Get all workspaces
WORKSPACES_JSON=$(niri msg -j workspaces)

# Build the text string
TEXT_STRING=$(echo "$WORKSPACES_JSON" | jq -r '.[] | if .is_focused then "<span color=\"#89b4fa\">\(.idx)</span>" else "\(.idx)" end' | paste -sd " " -)

# Construct the JSON object using jq to ensure correct escaping and output it compact
jq -n -c --arg text "$TEXT_STRING" '{"text": $text}'
