#!/bin/bash

# Define the log file paths
LOG_FILE="/tmp/yabai_${USER}.out.log"
DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"

# Function to log to debug file with timestamp
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S:%N')] SPACE_SETUP_HOME: $1" >> "$DEBUG_LOG_FILE"
}

# Log script start
debug_log "Script started"

# Redirect stdout and stderr to log file
exec > "$LOG_FILE" 2>&1

#
# setup spaces
#
function setup_space {
  local idx="$1"
  local name="$2"
  local space=
  local displays=$(yabai -m query --displays | jq 'length')
  local display_LUT=("1 1 1 1 1 1 1 1 1" "1 1 1 1 1 2 2 3 3" "1 1 1 2 2 2 3 3 4")
  local row_content=(${display_LUT[$displays - 1]})
  local display=${row_content[$idx - 1]}
  echo "setup space id:$idx display:$display name:$name"
  debug_log "Setting up space $idx on display $display with name '$name'"

  space=$(yabai -m query --spaces --space "$idx")
  if [ -z "$space" ]; then
    debug_log "Creating new space $idx"
    yabai -m space --create
  else
    debug_log "Space $idx already exists"
  fi

  if [ "${name}" != "" ]; then
    debug_log "Assigning space $idx to display $display with label '$name'"
    yabai -m space "$idx" --display "$display" --label "$name"
  else
    debug_log "Assigning space $idx to display $display (no label)"
    yabai -m space "$idx" --display "$display"
  fi
  # yabai -m space --focus "$idx"
}
function run_setup_spaces {
  echo " "
  echo "Setting up spaces..."
  debug_log "Starting space setup process"
  setup_space 1
  setup_space 2
  setup_space 3
  setup_space 4
  setup_space 5
  setup_space 6
  setup_space 7
  setup_space 8
  setup_space 9

  echo "Cleaning up spaces..."
  debug_log "Starting space cleanup (destroying spaces > 9)"
  local spaces_to_destroy=$(yabai -m query --spaces | jq '.[].index | select(. > 9)')
  if [ -n "$spaces_to_destroy" ]; then
    for _ in $spaces_to_destroy; do
      debug_log "Destroying space 10"
      yabai -m space --destroy 10
    done
  else
    debug_log "No extra spaces to clean up"
  fi
}

run_setup_spaces
debug_log "Reloading sketchybar"
sketchybar --reload

#
# add rules for automatic space assignment
#
echo " "
echo "Adding rules for automatic space assignment..."
debug_log "Starting rule assignment for automatic space placement"
debug_log "Adding rule: Spotify -> space 9"
yabai -m rule --add app="^Spotify$" space=^9
debug_log "Adding rule: Notion -> space 2"
yabai -m rule --add app="^Notion$" space=^2
debug_log "Adding rule: Warp -> space 5"
yabai -m rule --add app="^Warp$" space=^5
debug_log "Adding rule: Messenger -> space 6"
yabai -m rule --add app="^Messenger$" space=^6
debug_log "Adding rule: Signal -> space 6"
yabai -m rule --add app="^Signal$" space=^6
debug_log "Adding rule: Keymapp -> space 6"
yabai -m rule --add app="^Keymapp$" space=^6
debug_log "Adding rule: Slack -> space 7"
yabai -m rule --add app="^Slack$" space=^7
debug_log "Adding rule: Figma -> space 4"
yabai -m rule --add app="^Figma$" space=^4
debug_log "Adding rule: Reminders -> space 6"
yabai -m rule --add app="^Reminders$" space=^6

#
# move open apps
#
echo " "
echo "Moving apps between spaces..."
debug_log "Starting to move existing open applications to designated spaces"
apps=$(yabai -m query --windows | jq -r ".[].app" | uniq)
echo "Found apps:$apps"
debug_log "Found open applications: $(echo $apps | tr '\n' ' ')"

# Get list of applications with window IDs
app_windows=$(yabai -m query --windows | jq -r "group_by(.app)[] | {app: .[0].app, ids: [.[].id]}")

#echo "Found app windows: $app_windows"

# Loop through each application and its windows
if [ -n "${apps}" ]; then
  echo "$apps" | while IFS= read -r app; do
    echo " "
    echo "Processing: $app"
    debug_log "Processing application: $app"

    # Initialize space for each app
    space=1

    # Determine the space number based on the application name
    case "$app" in
      "Spotify") space=9 ;;
      "Notion") space=2 ;;
      "Warp") space=5 ;;
      "Messenger") space=6 ;;
      "Signal") space=6 ;;
      "Keymapp") space=6 ;;
      "Slack") space=7 ;;
      "Figma") space=4 ;;
      "Reminders") space=6 ;;
      # Add more cases as necessary
      *) debug_log "No space assignment rule for $app, skipping"; continue ;;
    esac

    debug_log "$app should be moved to space $space"

    # Get the window IDs for the application
    window_ids=$(echo $app_windows | jq -r "select(.app == \"$app\") | .ids[]")
    echo "Found window_ids for $app: $window_ids"
    debug_log "Found window IDs for $app: $(echo $window_ids | tr '\n' ' ')"

    # Move each window to the designated space
    for id in $window_ids; do
      echo "Moving window '$id' of $app to space $space"
      debug_log "Moving window ID $id of $app to space $space"
      yabai -m window $id --space $space
    done
  done
else
  echo "No open applications found."
  debug_log "No open applications found to move"
fi

debug_log "Focusing space 1"
yabai -m space --focus 1
debug_log "Script completed successfully"
