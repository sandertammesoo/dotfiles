#!/bin/bash

# Work layout: spaces per display count + app placement.
# All logic lives in space_setup_common.sh.

LOCATION="WORK"

# space -> display lookup: row N is the layout when N displays are connected
DISPLAY_LUT=(
  "1 1 1 1 1 1 1 1 1"
  "1 1 1 1 2 2 2 2 2"
  "1 1 1 1 2 2 3 3 3"
  "1 1 1 2 2 2 3 3 4"
)

# "App=space" pairs, used for both yabai rules and moving open windows
APP_SPACES=(
  "Spotify=6"
  "Notion=9"
  "Warp=4"
  "Messenger=5"
  "Signal=5"
  "Keymapp=6"
  "Figma=3"
)

source "$(dirname "$0")/space_setup_common.sh"
