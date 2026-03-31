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
      if [ "$app" = "Brave Browser" ]; then
        while IFS= read -r title; do
          icon_strip+=" $($CONFIG_DIR/plugins/brave_page_icon.sh "$title")"
        done <<< "$(yabai -m query --windows --space "$space" 2>/dev/null \
          | jq -r '.[] | select(.app == "Brave Browser") | .title')"
      else
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
      fi
    done <<< "${apps}"
  else
    icon_strip+=" —"
  fi
  
  sketchybar --set space.$space icon="$icon" label="$icon_strip"
fi