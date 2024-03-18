#!/bin/bash

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  apps="$(echo "$INFO" | jq -r '.apps | keys[]')"
  name="$(yabai -m query --spaces --space $space | jq -r '.label' | tr '[:lower:]' '[:upper:]')"
  
  icon=$space
  if [ "${name}" != "" ]; then
    icon+="-$name    􀆊"
  fi

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip+=" —"
  fi
  
  sketchybar --set space.$space icon="$icon" label="$icon_strip"
fi