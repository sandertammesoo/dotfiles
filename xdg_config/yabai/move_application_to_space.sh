#!/bin/bash

# Define the log file paths
LOG_FILE="/tmp/yabai_${USER}.out.log"
DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"

# Function to log to debug file with timestamp
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MOVE_APP_TO_SPACE: $1" >> "$DEBUG_LOG_FILE"
}

# Log script start
debug_log "Script started with space argument: $1"

# Redirect stdout and stderr to log file
exec >"$LOG_FILE" 2>&1

# Check if a space argument is provided
if [ -z "$1" ]; then
	echo "Error: No space number provided."
	echo "Usage: $0 <space-number>"
	debug_log "Error: No space number provided"
	exit 1
fi

# Assign the first argument to 'space'
space="$1"
debug_log "Target space set to: $space"

#
# move open apps
#
echo " "
echo "Moving app windows between spaces..."
debug_log "Starting to move focused application windows to space $space"
# Query the currently focused window
focused_app=$(yabai -m query --windows --window | jq -r ".app")

echo "Currently focused app: $focused_app"
debug_log "Currently focused app: $focused_app"

# Get list of applications with window IDs, but only for the focused application
app_windows=$(yabai -m query --windows | jq -r --arg focused_app "$focused_app" 'map(select(.app == $focused_app)) | group_by(.app)[] | {app: .[0].app, ids: [.[].id]}')

echo "Windows for focused app: $app_windows"
debug_log "Queried windows for focused app: $focused_app"

# Check if the focused app is not empty
if [ -n "${focused_app}" ]; then
	echo "Processing: $focused_app"
	debug_log "Processing focused application: $focused_app"

	# Get the window IDs for the focused application
	window_ids=$(echo $app_windows | jq -r "select(.app == \"$focused_app\") | .ids[]")
	echo "Found window_ids for $focused_app: $window_ids"
	debug_log "Found window IDs for $focused_app: $(echo $window_ids | tr '\n' ' ')"

	# Move each window to the designated space
	for id in $window_ids; do
		echo "Moving window '$id' of $focused_app to space $space"
		debug_log "Moving window ID $id of $focused_app to space $space"
		yabai -m window $id --space $space
	done
	debug_log "Focusing space $space after moving windows"
	yabai -m space --focus $space
	debug_log "Script completed successfully - moved $focused_app to space $space"
else
	echo "No focused application found."
	debug_log "No focused application found - nothing to move"
fi
