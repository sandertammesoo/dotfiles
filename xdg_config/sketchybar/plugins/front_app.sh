#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" != "front_app_switched" ] && [ "$SENDER" != "title_change" ] && [ "$SENDER" != "window_focus" ]; then
  exit 0
fi

WINDOW_INFO=$(yabai -m query --windows --window)
APP=$(echo "$WINDOW_INFO" | jq -r '.app')
WINDOW_TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')

if [[ $WINDOW_TITLE = "" ]]; then
  LABEL="$APP"
elif [[ ${#WINDOW_TITLE} -gt 50 ]]; then
  LABEL="${WINDOW_TITLE:0:50}..."
else
  LABEL="$WINDOW_TITLE"
fi

if [ "$APP" = "Brave Browser" ]; then
  sketchybar --set $NAME label="$LABEL" icon="$($CONFIG_DIR/plugins/brave_page_icon.sh "$WINDOW_TITLE")"
elif [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "window_focus" ]; then
  sketchybar --set $NAME label="$LABEL" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$APP")"
else
  sketchybar --set $NAME label="$LABEL"
fi
