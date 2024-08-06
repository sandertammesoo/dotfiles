#!/bin/bash

# SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

# for sid in "${SPACE_SIDS[@]}"
# do
#   sketchybar --add space space.$sid left     \
#              --set space.$sid space=$sid           \
#                               icon=$sid              \
#                               label.font="sketchybar-app-font:Regular:16.0"  \
#                               label.padding_right=20                   \
#                               label.y_offset=-1                       \
#                               script="$PLUGIN_DIR/space.sh"
# done

##### Adding Mission Control Space Indicators #####
# Now we add some mission control spaces:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item
# to indicate active and available mission control spaces

#DISPLAY_IDS=($(yabai -m query --displays | jq -r '.[].id'))
DISPLAY_IDS=($(yabai -m query --displays | jq -r 'sort_by(.id) | reverse | .[].id'))

# Get the number of displays
num_displays=${#DISPLAY_IDS[@]}

for i in "${!DISPLAY_IDS[@]}"
do
  #sid=$(($i+1))
  sid=$(($num_displays - $i))
  sketchybar --add item display.$sid right                                 \
             --set display.$sid icon=${DISPLAY_IDS[i]}                     \
                              icon.padding_left=16 \
                              script="$PLUGIN_DIR/display.sh"         \
             --subscribe display.$sid display_change
done

# sketchybar --add item space_separator center                          \
#            --set space_separator icon="􀆊"                           \
#                                  icon.color=$ACCENT_COLOR           \
#                                  icon.padding_left=4                \
#                                  label.drawing=off                  \
#                                  background.drawing=off             \
#                                  script="$PLUGIN_DIR/space_windows.sh" \
#            --subscribe space_separator space_windows_change
