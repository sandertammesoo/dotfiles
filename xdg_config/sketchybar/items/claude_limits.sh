#!/bin/bash

# Claude Code rate limit items (right side)
# Data is written to /tmp/claude_rate_limits.json by ~/.claude/statusline-command.sh

PLUGIN="$PLUGIN_DIR/claude_limits.sh"

sketchybar --add event claude_limits_update \
           \
           --add item claude_7d right \
           --set claude_7d  icon="󰃰" \
                            icon.font="$FONT_FACE:Bold:13.0" \
                            label="--" \
                            label.color=$WHITE \
                            icon.color=$WHITE \
                            update_freq=30 \
                            script="$PLUGIN" \
           --subscribe claude_7d claude_limits_update \
           \
           --add item claude_5h right \
           --set claude_5h  icon="󱑂" \
                            icon.font="$FONT_FACE:Bold:13.0" \
                            label="--" \
                            label.color=$WHITE \
                            icon.color=$WHITE \
                            update_freq=30 \
                            script="$PLUGIN" \
           --subscribe claude_5h claude_limits_update
