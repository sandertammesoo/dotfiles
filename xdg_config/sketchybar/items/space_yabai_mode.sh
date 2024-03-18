#!/bin/bash

sketchybar --add item space_yabai_mode right \
           --set space_yabai_mode update_freq=3 \
                            label.font="SF Pro:Semibold:15.0" \
                            label.padding_left=0                   \
                            icon=""\
                            icon.font="Hack Nerd Font:Regular:16.0" \
                            script="$PLUGIN_DIR/space_yabai_mode.sh" \
                            click_script="$PLUGIN_DIR/space_yabai_mode_click.sh" \
           --subscribe space_yabai_mode space_change