#!/bin/bash

# Define the log file path
LOG_FILE="/tmp/yabai_${USER}.out.log"

# Redirect stdout and stderr to log file
exec > "$LOG_FILE" 2>&1

# Check if a space argument is provided
if [ -z "$1" ]; then
    echo "Error: No space number provided."
    echo "Usage: $0 <space-number>"
    exit 1
fi

# Assign the first argument to 'space'
space="$1"

#
# move open apps
#
echo " "
echo "Moving app windows between spaces..."
# Query the currently focused window
focused_app=$(yabai -m query --windows --window | jq -r ".app")

echo "Currently focused app: $focused_app"

# Get list of applications with window IDs, but only for the focused application
app_windows=$(yabai -m query --windows | jq -r --arg focused_app "$focused_app" 'map(select(.app == $focused_app)) | group_by(.app)[] | {app: .[0].app, ids: [.[].id]}')

echo "Windows for focused app: $app_windows"

# Check if the focused app is not empty
if [ -n "${focused_app}" ]; then
    echo "Processing: $focused_app"

    # Get the window IDs for the focused application
    window_ids=$(echo $app_windows | jq -r "select(.app == \"$focused_app\") | .ids[]")
    echo "Found window_ids for $focused_app: $window_ids"

    # Move each window to the designated space
    for id in $window_ids; do
        echo "Moving window '$id' of $focused_app to space $space"
        yabai -m window $id --space $space
    done
else
    echo "No focused application found."
fi
