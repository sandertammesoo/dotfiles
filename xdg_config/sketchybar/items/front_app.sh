#!/bin/bash

sketchybar -m --add event window_focus \
              --add event title_change

# Add one instance per landscape display (portrait displays are too narrow)
for _display_id in "${LANDSCAPE_DISPLAYS[@]}"; do
  sketchybar --add item "front_app_d${_display_id}" center \
             --set "front_app_d${_display_id}" \
                   display=$_display_id \
                   background.color=$ACCENT_COLOR \
                   icon.color=$BAR_COLOR \
                   icon.font="sketchybar-app-font:Regular:16.0" \
                   label.color=$BAR_COLOR \
                   script="$PLUGIN_DIR/front_app.sh" \
             --subscribe "front_app_d${_display_id}" front_app_switched title_change window_focus
done