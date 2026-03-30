#!/bin/bash

# Claude Code rate limit items (right side)
# Fetched from the Anthropic OAuth API by plugins/claude_fetch_usage.sh

PLUGIN="$PLUGIN_DIR/claude_limits.sh"

sketchybar --add event claude_limits_update \
           \
           --add item claude_7d right \
           --set claude_7d  icon="󰃰" \
                            icon.font="$FONT_FACE:Bold:13.0" \
                            label="--" \
                            label.color=$WHITE \
                            icon.color=$WHITE \
                            background.drawing=off \
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
                            background.drawing=off \
                            update_freq=30 \
                            script="$PLUGIN" \
           --subscribe claude_5h claude_limits_update \
           \
           --add item claude_icon right \
           --set claude_icon icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "Claude")" \
                             icon.font="sketchybar-app-font:Regular:16.0" \
                             icon.color=$WHITE \
                             label.drawing=off \
                             background.drawing=off \
                             padding_right=0 \
           \
           --add bracket claude_bracket claude_icon claude_5h claude_7d \
           --set claude_bracket background.color=$ITEM_BG_COLOR_SEC \
                                background.corner_radius=5 \
                                background.height=24
