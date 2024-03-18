#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # W I N D O W  T I T L E
  APP=$(yabai -m query --windows --window | jq -r '.app') 
  WINDOW_TITLE=$(yabai -m query --windows --window | jq -r '.title')

  if [[ $WINDOW_TITLE = "" ]]; then
  sketchybar --set $NAME label="$APP" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$INFO")"
  exit 0
  fi

  if [[ ${#WINDOW_TITLE} -gt 50 ]]; then
  WINDOW_TITLE=$(echo "$WINDOW_TITLE" | cut -c 1-50)
  sketchybar --set $NAME label="$APP │ $WINDOW_TITLE..." icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$INFO")"
  exit 0
  fi

  sketchybar --set $NAME label="$APP │ $WINDOW_TITLE" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$INFO")"

elif [ "$SENDER" = "title_change" ]; then
  # W I N D O W  T I T L E 
  APP=$(yabai -m query --windows --window | jq -r '.app') 
  WINDOW_TITLE=$(yabai -m query --windows --window | jq -r '.title')

  if [[ $WINDOW_TITLE = "" ]]; then
  sketchybar --set $NAME label="$APP"
  exit 0
  fi

  if [[ ${#WINDOW_TITLE} -gt 50 ]]; then
  WINDOW_TITLE=$(echo "$WINDOW_TITLE" | cut -c 1-50)
  sketchybar --set $NAME label="$APP │ $WINDOW_TITLE..."
  exit 0
  fi

  sketchybar --set $NAME label="$APP │ $WINDOW_TITLE"

fi