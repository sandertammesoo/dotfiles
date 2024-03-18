#!/bin/bash

# Define the log file path
LOG_FILE="/tmp/yabai_${USER}.out.log"

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
  local display_LUT=("1 1 1 1 1 1 1 1 1" "1 1 1 1 2 2 2 2 2" "1 1 1 1 2 2 2 3 3" "1 1 1 1 2 2 2 3 4")
  local row_content=(${display_LUT[$displays - 1]})
  local display=${row_content[$idx - 1]}
  echo "setup space id:$idx display:$display name:$name"

  space=$(yabai -m query --spaces --space "$idx")
  if [ -z "$space" ]; then
    yabai -m space --create
  fi
  
  if [ "${name}" != "" ]; then
    yabai -m space "$idx" --display "$display" --label "$name"
  else
    yabai -m space "$idx" --display "$display"
  fi
  yabai -m space --focus "$idx"
}
echo " "
echo "Setting up spaces..."
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
for _ in $(yabai -m query --spaces | jq '.[].index | select(. > 9)'); do
  yabai -m space --destroy 10
done

#
# move open apps
#
echo " "
echo "Moving apps between spaces..."
apps=$(yabai -m query --windows | jq -r ".[].app"  | uniq)
echo "Found apps:$apps"

# Get list of applications with window IDs
app_windows=$(yabai -m query --windows | jq -r "group_by(.app)[] | {app: .[0].app, ids: [.[].id]}")

#echo "Found app windows: $app_windows"

# Loop through each application and its windows
if [ -n "${apps}" ]; then
    echo "$apps" | while IFS= read -r app; do
        echo " "
        echo "Processing: $app"

        # Initialize space for each app
        space=1

        # Determine the space number based on the application name
        case "$app" in
            "Spotify") space=1 ;;
            "Notion") space=2 ;;
            "Warp") space=3 ;;
            "Code") space=3 ;;
            "Jira Advanced Agile Board") space=5 ;;
            "Gmail") space=6 ;;
            "Fractory Gmail") space=6 ;;
            "Reclaim") space=7 ;;
            "Fractory GCal") space=7 ;;
            "Notion Calendar") space=7 ;;
            "Messenger") space=8 ;;
            "Signal") space=8 ;;
            "Keymapp") space=8 ;;
            "Slack") space=5 ;;
            "Figma") space=4 ;;
            # Add more cases as necessary
            *) continue ;;
        esac

        # Get the window IDs for the application
        window_ids=$(echo $app_windows | jq -r "select(.app == \"$app\") | .ids[]")
        echo "Found window_ids for $app: $window_ids"

        # Move each window to the designated space
        for id in $window_ids; do
            echo "Moving window '$id' of $app to space $space"
            yabai -m window $id --space $space
        done
    done
else
    echo "No open applications found."
fi

# move some apps automatically to specific spaces
yabai -m rule --add app="^Spotify$" space=^1
yabai -m rule --add app="^Notion$" space=^2
yabai -m rule --add app="^Warp$" space=^3
yabai -m rule --add app="^Code$" space=^3
yabai -m rule --add app="^Jira Advanced Agile Board$" space=^5
yabai -m rule --add app="^Gmail$" space=^6
yabai -m rule --add app="^Fractory Gmail$" space=^6
yabai -m rule --add app="^Reclaim$" space=^7
yabai -m rule --add app="^Fractory GCal$" space=^7
yabai -m rule --add app="^Notion Calendar$" space=^7
yabai -m rule --add app="^Messenger$" space=^8
yabai -m rule --add app="^Signal$" space=^8
yabai -m rule --add app="^Keymapp$" space=^8
yabai -m rule --add app="^Slack$" space=^5
yabai -m rule --add app="^Figma$" space=^4

yabai -m space --focus 1