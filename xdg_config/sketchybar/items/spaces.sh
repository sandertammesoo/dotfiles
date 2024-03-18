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

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")

for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                 \
             --set space.$sid space=$sid                                 \
                              icon=${SPACE_ICONS[i]}                     \
                              label.font="sketchybar-app-font:Regular:16.0"  \
                              label.padding_right=20                   \
                              label.y_offset=-1                       \
                              script="$PLUGIN_DIR/space.sh"              \
                              click_script="yabai -m space --focus $sid"
done

sketchybar --add item space_separator left                          \
           --set space_separator icon="􀆊"                           \
                                 icon.color=$ACCENT_COLOR           \
                                 icon.padding_left=4                \
                                 label.drawing=off                  \
                                 background.drawing=off             \
                                 script="$PLUGIN_DIR/space_windows.sh" \
           --subscribe space_separator space_windows_change