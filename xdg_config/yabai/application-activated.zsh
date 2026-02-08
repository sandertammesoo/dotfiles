#! /usr/bin/zsh

# When there are more than 3 windows open on the current space we stack Google
# Chrome and Transmit along with stacking VSCode and Tower if both are open.

# Define the debug log file path
DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"
LOCK_FILE="/tmp/yabai_app_activated.lock"

# Function to log to debug file with timestamp
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S:%N')] APP_ACTIVATED: $1" >> "$DEBUG_LOG_FILE"
}

# CRITICAL: Prevent cascade by implementing rate limiting
# Exit immediately if script ran recently (within 2 seconds)
if [[ -f "$LOCK_FILE" ]]; then
    local lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || echo 0) ))
    if [[ $lock_age -lt 2 ]]; then
        debug_log "Script skipped - rate limited (last run ${lock_age}s ago)"
        exit 0
    fi
fi

# Create lock file to prevent rapid re-execution
touch "$LOCK_FILE"

# Log script start
debug_log "Script started - checking for window stacking conditions"

# Get all the windows on current space
local WINDOWS_ARRAY=$(yabai -m query --spaces --space \
  | jq -re ".index" \
  | xargs -I{} yabai -m query --windows --space {} \
  | jq -r 'map(select(.["is-minimized"]==false and .["is-floating"]==false))')

# Get the number of windows on the current space
local NUMBER_OF_WINDOWS=$(echo $WINDOWS_ARRAY | jq -r 'length')
debug_log "Found $NUMBER_OF_WINDOWS non-minimized, non-floating windows on current space"

# If we are Less than or equal to 3 windows on current space exit script
if [ "$NUMBER_OF_WINDOWS" -le "3" ]; then
    debug_log "Only $NUMBER_OF_WINDOWS windows found - no stacking needed (threshold: 3)"
    return 42
fi

debug_log "More than 3 windows detected - proceeding with stacking logic"

# Stack first instance of VSCode and Tower when more than 3 windows
local VSCODE_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Code")) | .[0] | .id')
local TOWER_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Tower")) | .[0] | .id')

debug_log "VSCode window ID: $VSCODE_ID, Tower window ID: $TOWER_ID"

if [[ $VSCODE_ID != 'null' && $TOWER_ID != 'null' ]]; then;
    debug_log "Stacking VSCode (ID: $VSCODE_ID) with Tower (ID: $TOWER_ID)"
    yabai -m window $VSCODE_ID --stack $TOWER_ID
else
    debug_log "VSCode/Tower stacking skipped - one or both apps not found"
fi

# Stack first instance of Google Chrome and Transmit when more than 3 windows
local CHROME_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Google Chrome")) | .[0] | .id')
local TRANSMIT_ID=$(echo $WINDOWS_ARRAY | jq -r 'map(select(.app=="Transmit")) | .[0] | .id')

debug_log "Chrome window ID: $CHROME_ID, Transmit window ID: $TRANSMIT_ID"

if [[ $CHROME_ID != 'null' && $TRANSMIT_ID != 'null' ]]; then;
    debug_log "Stacking Chrome (ID: $CHROME_ID) with Transmit (ID: $TRANSMIT_ID)"
    yabai -m window $CHROME_ID --stack $TRANSMIT_ID
else
    debug_log "Chrome/Transmit stacking skipped - one or both apps not found"
fi

debug_log "Script completed - stacking logic finished"

# Clean up lock file on successful completion
rm -f "$LOCK_FILE" 2>/dev/null