# shellcheck shell=bash
# Shared logic for space_setup_work.sh / space_setup_home.sh.
# Sourced, not executed. The sourcing script must define:
#   LOCATION     - tag for debug log lines (e.g. "WORK", "HOME")
#   DISPLAY_LUT  - space->display lookup rows, one row per display count
#   APP_SPACES   - "App=space" pairs for rules and moving open windows

LOG_FILE="/tmp/yabai_${USER}.out.log"
DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"

debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S:%N')] SPACE_SETUP_${LOCATION}: $1" >> "$DEBUG_LOG_FILE"
}

debug_log "Script started"

# Redirect stdout and stderr to log file
exec > "$LOG_FILE" 2>&1

#
# setup spaces
#
run_setup_spaces() {
  echo " "
  echo "Setting up spaces..."
  debug_log "Starting space setup process"

  local displays
  displays=$(yabai -m query --displays | jq 'length')
  local targets=(${DISPLAY_LUT[$displays - 1]})

  # Ensure exactly 9 spaces exist before moving anything, so the
  # LUT indices below refer to a settled space count.
  local total
  total=$(yabai -m query --spaces | jq 'length')
  while (( total < 9 )); do
    debug_log "Creating space ($total -> $((total + 1)))"
    yabai -m space --create
    (( total++ ))
  done
  # Destroying a display's only space fails, so walk down from the
  # highest index until one destroys.
  local destroyed candidate
  while (( total > 9 )); do
    destroyed=false
    for (( candidate = total; candidate >= 1; candidate-- )); do
      if yabai -m space --destroy "$candidate"; then
        debug_log "Destroyed space $candidate"
        destroyed=true
        break
      fi
    done
    if [[ "$destroyed" == "false" ]]; then
      debug_log "Could not destroy any space; giving up cleanup"
      break
    fi
    (( total-- ))
  done

  # Moving a space to another display renumbers ALL mission-control
  # indices, so after each move re-scan from a fresh query instead of
  # trusting indices computed before the move. Everything left of the
  # first mismatch is already correct, so each move makes progress and
  # a single script run converges. The pass cap only guards yabai errors.
  local pass idx current changed
  for pass in 1 2 3 4 5 6 7 8 9; do
    changed=false
    for idx in 1 2 3 4 5 6 7 8 9; do
      current=$(yabai -m query --spaces --space "$idx" | jq '.display')
      if [[ "$current" != "${targets[$idx - 1]}" ]]; then
        echo "moving space $idx to display ${targets[$idx - 1]}"
        debug_log "Moving space $idx to display ${targets[$idx - 1]}"
        if yabai -m space "$idx" --display "${targets[$idx - 1]}"; then
          changed=true
          break # indices are stale now; re-scan
        fi
        # Failed move (e.g. LUT names a display that is not connected):
        # nothing was renumbered, so keep scanning this pass.
        debug_log "Failed to move space $idx to display ${targets[$idx - 1]}"
      fi
    done
    [[ "$changed" == "false" ]] && break
  done
}

#
# rules for automatic space assignment
#
setup_rules() {
  echo " "
  echo "Adding rules for automatic space assignment..."
  debug_log "Starting rule assignment for automatic space placement"

  # Drop rules from any previous run (either location) so switching
  # between home and work swaps the rule set instead of stacking it.
  local label
  yabai -m rule --list | jq -r '.[].label | select(startswith("space_setup_"))' |
    while IFS= read -r label; do
      debug_log "Removing stale rule: $label"
      yabai -m rule --remove "$label"
    done

  local entry app space
  for entry in "${APP_SPACES[@]}"; do
    app="${entry%%=*}"
    space="${entry##*=}"
    debug_log "Adding rule: $app -> space $space"
    yabai -m rule --add label="space_setup_${app}" app="^${app}\$" space="^${space}"
  done
}

#
# move open apps
#
move_open_windows() {
  echo " "
  echo "Moving apps between spaces..."
  debug_log "Starting to move existing open applications to designated spaces"

  local windows
  windows=$(yabai -m query --windows)

  local entry app space window_ids id
  for entry in "${APP_SPACES[@]}"; do
    app="${entry%%=*}"
    space="${entry##*=}"
    window_ids=$(echo "$windows" | jq -r --arg app "$app" '.[] | select(.app == $app) | .id')
    [[ -z "$window_ids" ]] && { debug_log "No open windows for $app"; continue; }
    for id in $window_ids; do
      echo "Moving window '$id' of $app to space $space"
      debug_log "Moving window ID $id of $app to space $space"
      yabai -m window "$id" --space "$space"
    done
  done
}

run_setup_spaces
debug_log "Reloading sketchybar"
sketchybar --reload
setup_rules
move_open_windows
debug_log "Focusing space 1"
yabai -m space --focus 1
debug_log "Script completed successfully"
