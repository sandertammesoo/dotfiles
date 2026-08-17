#!/bin/bash

# Home layout: spaces per display count + app placement.
# All logic lives in space_setup_common.sh.

LOCATION="HOME"

# space -> display lookup: row N is the layout when N displays are connected
DISPLAY_LUT=(
  "1 1 1 1 1 1 1 1 1"
  "1 1 1 1 1 2 2 3 3"
  "1 1 1 2 2 2 3 3 4"
)

# "App=space" pairs, used for both yabai rules and moving open windows
APP_SPACES=(
  "Spotify=9"
  "Notion=2"
  "Warp=5"
  "Messenger=6"
  "Signal=6"
  "Keymapp=6"
  "Slack=7"
  "Figma=4"
  "Reminders=6"
)

source "$(dirname "$0")/space_setup_common.sh"
