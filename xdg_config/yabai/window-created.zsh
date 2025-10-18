#! /usr/bin/zsh

is_app() {
    echo $(yabai -m query --spaces --space \
        | jq -re ".index" \
        | xargs -I{} yabai -m query --windows --space {} \
        | jq -r 'map(select(.id=='$YABAI_WINDOW_ID' and .app=="'$1'" and .subrole=="AXStandardWindow")) | .[] | [.app][]')
}

if [[ $(is_app "Finder") == "Finder" ]]; then
    # Use grid-based positioning for better cross-display compatibility
    # Grid: 20 rows, 30 cols, start at (0,14), span 20 cols x 6 rows
    # This positions Finder window at bottom of screen with consistent proportions
    yabai -m window --focus $YABAI_WINDOW_ID \
        & yabai -m window --grid 20:30:0:14:20:6
fi