#! /usr/bin/zsh

# Define the debug log file path
DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"

# Function to log to debug file with timestamp
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S:%N')] WINDOW_CREATED: $1" >> "$DEBUG_LOG_FILE"
}

# Log script start
debug_log "Script started for window ID: $YABAI_WINDOW_ID"

is_app() {
    echo $(yabai -m query --spaces --space \
        | jq -re ".index" \
        | xargs -I{} yabai -m query --windows --space {} \
        | jq -r 'map(select(.id=='$YABAI_WINDOW_ID' and .app=="'$1'" and .subrole=="AXStandardWindow")) | .[] | [.app][]')
}

debug_log "Checking if window belongs to Finder app"

if [[ $(is_app "Finder") == "Finder" ]]; then
    debug_log "Finder window detected - applying custom grid positioning"
    debug_log "Positioning Finder window (ID: $YABAI_WINDOW_ID) at bottom of screen with grid 20:30:0:14:20:6"
    # Use grid-based positioning for better cross-display compatibility
    # Grid: 20 rows, 30 cols, start at (0,14), span 20 cols x 6 rows
    # This positions Finder window at bottom of screen with consistent proportions
    yabai -m window --focus $YABAI_WINDOW_ID \
        & yabai -m window --grid 30:20:4:4:12:24
    debug_log "Finder window positioning completed"
else
    debug_log "Window is not a Finder window - no special positioning needed"
fi

debug_log "Script completed for window ID: $YABAI_WINDOW_ID"