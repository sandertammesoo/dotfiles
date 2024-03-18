#!/bin/bash

space_number=$(yabai -m query --spaces --space | jq -r .index)
yabai_mode=$(yabai -m query --spaces --space | jq -r .type)

case "$yabai_mode" in
    bsp)
    sketchybar -m --set space_yabai_mode label="bsp"
    ;;
    stack)
    sketchybar -m --set space_yabai_mode label="stack"
    ;;
    float)
    sketchybar -m --set space_yabai_mode label="flaot"
    ;;
esac