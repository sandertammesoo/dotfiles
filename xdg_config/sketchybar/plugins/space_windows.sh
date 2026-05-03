#!/bin/bash

if [ "$SENDER" = "title_change" ]; then
  # Only Brave has title-based icon changes — skip all other apps
  app="$(yabai -m query --windows --window 2>/dev/null | jq -r '.app')"
  [ "$app" != "Brave Browser" ] && exit 0

  space="$(yabai -m query --windows --window 2>/dev/null | jq -r '.space')"
  [ -z "$space" ] && exit 0

  icon_strip=" "
  while IFS= read -r title; do
    [ -z "$title" ] && continue
    icon_strip+=" $($CONFIG_DIR/plugins/brave_page_icon.sh "$title")"
  done <<< "$(yabai -m query --windows --space "$space" 2>/dev/null \
    | jq -r '.[] | select(.app == "Brave Browser" and (."is-minimized" == false) and (.title | IN("", "Picture in Picture") | not)) | .title')"

  sketchybar --set space.$space label="$icon_strip"

elif [ "$SENDER" = "space_windows_change" ]; then
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
          [ -z "$title" ] && continue
          icon_strip+=" $($CONFIG_DIR/plugins/brave_page_icon.sh "$title")"
        done <<< "$(yabai -m query --windows --space "$space" 2>/dev/null \
          | jq -r '.[] | select(.app == "Brave Browser" and (."is-minimized" == false) and (.title | IN("", "Picture in Picture") | not)) | .title')"
      elif [ "$app" = "1Password" ]; then
        # Skip if the only 1Password windows on this space are Quick Access overlays
        has_real=$(yabai -m query --windows --space "$space" 2>/dev/null \
          | jq -r '[.[] | select(.app == "1Password" and (."is-minimized" == false) and (.title | test("^Quick Access") | not))] | length')
        [ "${has_real:-0}" -gt 0 ] && icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
      else
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
      fi
    done <<< "${apps}"
  else
    icon_strip+=" —"
  fi

  sketchybar --set space.$space icon="$icon" label="$icon_strip"
fi