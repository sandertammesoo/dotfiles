#!/bin/bash

# Claude Code rate limit items (right side)
# Fetched from the Anthropic OAuth API by plugins/claude_fetch_usage.sh
# Added once per landscape display (portrait displays are too narrow)

PLUGIN="$PLUGIN_DIR/claude_limits.sh"
CLAUDE_ICON="$($CONFIG_DIR/plugins/icon_map_fn.sh "Claude")"

sketchybar --add event claude_limits_update

for _display_id in "${LANDSCAPE_DISPLAYS[@]}"; do
  sketchybar \
    --add item "claude_7d_d${_display_id}" right \
    --set "claude_7d_d${_display_id}" \
          display=$_display_id \
          icon="󰃰" \
          icon.font="$FONT_FACE:Bold:13.0" \
          label="--" \
          label.color=$WHITE \
          icon.color=$WHITE \
          background.drawing=off \
          script="$PLUGIN" \
    --subscribe "claude_7d_d${_display_id}" claude_limits_update \
    \
    --add item "claude_5h_d${_display_id}" right \
    --set "claude_5h_d${_display_id}" \
          display=$_display_id \
          icon="󱑂" \
          icon.font="$FONT_FACE:Bold:13.0" \
          label="--" \
          label.color=$WHITE \
          icon.color=$WHITE \
          background.drawing=off \
          update_freq=30 \
          script="$PLUGIN" \
    --subscribe "claude_5h_d${_display_id}" claude_limits_update \
    \
    --add item "claude_icon_d${_display_id}" right \
    --set "claude_icon_d${_display_id}" \
          display=$_display_id \
          icon="$CLAUDE_ICON" \
          icon.font="sketchybar-app-font:Regular:16.0" \
          icon.color=$WHITE \
          label.drawing=off \
          background.drawing=off \
          padding_right=0 \
    \
    --add bracket "claude_bracket_d${_display_id}" \
                  "claude_icon_d${_display_id}" \
                  "claude_5h_d${_display_id}" \
                  "claude_7d_d${_display_id}" \
    --set "claude_bracket_d${_display_id}" \
          background.color=$ITEM_BG_COLOR_SEC \
          background.corner_radius=5 \
          background.height=24
done
