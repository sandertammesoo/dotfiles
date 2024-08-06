#!/bin/bash

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

# if [ $SELECTED = true ]; then
#   sketchybar --set $NAME background.drawing=on \
#                          background.color=$ACCENT_COLOR \
#                          label.color=$BAR_COLOR \
#                          icon.color=$BAR_COLOR
# else
#   sketchybar --set $NAME background.drawing=off \
#                          label.color=$ACCENT_COLOR \
#                          icon.color=$ACCENT_COLOR
# fi

if [[ "$SENDER" = "display_change" ]]; then

  #DISPLAY_IDS=($(yabai -m query --displays | jq -r '.[].id'))
  DISPLAY_IDS=($(yabai -m query --displays | jq -r 'sort_by(.id) | reverse | .[].id'))

  # Get the number of displays
  num_displays=${#DISPLAY_IDS[@]}

  for i in "${!DISPLAY_IDS[@]}"
  do
    #sid=$(($i+1))
    sid=$(($num_displays - $i))
    sketchybar --set display.$sid background.drawing=off \
                          label.color=$ACCENT_COLOR \
                          icon.color=$ACCENT_COLOR
  done

  sketchybar --set display.$INFO background.drawing=on \
                          background.color=$ACCENT_COLOR \
                          label.color=$BAR_COLOR \
                          icon.color=$BAR_COLOR

fi
