#!/bin/bash

# M O D A L  I N D I C A T O R 
# sketchybar -m --add item modal right --set modal icon="􀇳" label="NO MODE"
# sketchybar -m --set modal icon_color =0xFF83A1F1
# sketchybar -m --add item modal right --set modal icon="󰹋" label.drawing=off

ITEM_NAME=modal
OPTIONS=(
    icon="󰹋" 
    label.drawing=off
    icon.padding_left=8
    icon.padding_right=8
)

sketchybar -m --add item $ITEM_NAME right \
              --set $ITEM_NAME "${OPTIONS[@]}"