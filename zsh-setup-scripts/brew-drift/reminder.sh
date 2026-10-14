#!/usr/bin/env zsh
#
# Weekly brew-drift reminder, run by the launchd agent that setup.sh writes.
# It runs `brew-drift status`. On drift, it saves the report and shows a
# notification. With no drift, it shows nothing.

source "${${(%):-%x}:A:h:h:h}/helpers_logging.zsh"

local report="${XDG_STATE_HOME:-$HOME/.local/state}/brew-drift/status.txt"

# The message goes in as an argument, not as AppleScript source, so a quote
# in a path cannot break it.
notify() {
  osascript -e 'on run argv' \
    -e 'display notification (item 1 of argv) with title "brew-drift"' \
    -e 'end run' "$1"
}

local bin="${BREW_DRIFT_BIN:-$(command -v brew-drift)}"
if [[ ! -x "$bin" ]]; then
  log_error "brew-drift is not installed. Run make install in ~/projects/utils/brew-drift."
  notify "brew-drift is not installed. The weekly drift check did not run."
  exit 1
fi

mkdir -p "${report:h}" || exit 1
"$bin" status > "$report" 2>&1
case $? in
  0) log_info "brew-drift: no drift" ;;
  1) log_info "brew-drift: drift found, report in ${report}"
     notify "Homebrew drift found. Run brew-drift fix. Report: ${report}" ;;
  *) log_error "brew-drift status failed. Output in ${report}"
     notify "brew-drift status failed. Output: ${report}"
     exit 1 ;;
esac
