#!/bin/bash

# wl_volume_change is triggered by the skhd media-key bindings, so the label
# updates the moment a key changes the Wave Link mix. update_freq covers the
# changes made in the Wave Link window itself, which send no event.
sketchybar --add event wl_volume_change

sketchybar --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
                        update_freq=10 \
           --subscribe volume volume_change wl_volume_change
