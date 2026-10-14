#!/usr/bin/env zsh
#
# brew-drift integration: the local config of this machine and the weekly
# reminder. Sourced by ./install.sh (install-all) and by install-server.
#
# The installers run before brew-drift is installed, so nothing here calls
# the binary. The repo config is brewfiles/brew-drift.toml.

# The repo root, from the location of this file.
BREW_DRIFT_DOTFILES="${${(%):-%x}:A:h:h:h}"
BREW_DRIFT_REPO_CONFIG="${BREW_DRIFT_DOTFILES}/brewfiles/brew-drift.toml"
BREW_DRIFT_LABEL="com.sandertammesoo.brew-drift-reminder"

# brew_drift_write_local_config PROFILE — write
# $XDG_CONFIG_HOME/brew-drift/config.toml with the repo config and PROFILE.
# An existing file stays: it can hold `skipped` entries of this machine.
brew_drift_write_local_config() {
  local profile="$1"
  local config="${XDG_CONFIG_HOME:-$HOME/.config}/brew-drift/config.toml"

  # A fixed-string match, so a profile name is never read as a pattern.
  if [[ ! -r "$BREW_DRIFT_REPO_CONFIG" || "$(<"$BREW_DRIFT_REPO_CONFIG")" != *$'\n'"${profile} = "* ]]; then
    log_error "brew-drift: ${BREW_DRIFT_REPO_CONFIG} has no profile '${profile}'"
    return 1
  fi
  if [[ -e "$config" ]]; then
    log_skip "brew-drift local config exists, not changed: ${config}"
    return 0
  fi

  mkdir -p "${config:h}" || return 1
  printf '# Written by the dotfiles installer. Edit it freely: it is not overwritten.\nrepo = "%s"\nprofile = "%s"\n' \
    "$BREW_DRIFT_REPO_CONFIG" "$profile" > "$config" || return 1
  log_success "brew-drift local config written: ${config} (profile ${profile})"
}

# brew_drift_install_reminder — write and load a launchd agent that runs
# reminder.sh each Monday at 10:00. Not at shell start: a run takes 1–2 s.
brew_drift_install_reminder() {
  local agents_dir="${BREW_DRIFT_LAUNCH_AGENTS_DIR:-$HOME/Library/LaunchAgents}"
  local plist="${agents_dir}/${BREW_DRIFT_LABEL}.plist"
  local script="${BREW_DRIFT_DOTFILES}/zsh-setup-scripts/brew-drift/reminder.sh"
  local log="${XDG_STATE_HOME:-$HOME/.local/state}/brew-drift/reminder.log"

  mkdir -p "$agents_dir" "${log:h}" || return 1
  # launchd starts jobs with a minimal PATH. brew-drift calls brew and mas.
  cat > "$plist" <<EOF || return 1
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${BREW_DRIFT_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>${script}</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>${HOME}/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>1</integer>
    <key>Hour</key>
    <integer>10</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${log}</string>
  <key>StandardErrorPath</key>
  <string>${log}</string>
</dict>
</plist>
EOF

  # Over SSH there is no GUI domain to load into. launchd loads the plist
  # from ~/Library/LaunchAgents at the next GUI login.
  if ! launchctl print "gui/${UID}" &>/dev/null; then
    log_warn "brew-drift: no GUI session; the reminder loads at the next login: ${plist}"
    return 0
  fi

  # bootout fails when the agent is not loaded yet; that is expected.
  # bootout finishes asynchronously, so a bootstrap right after it can fail
  # with "5: Input/output error". Try once more after a second.
  launchctl bootout "gui/${UID}/${BREW_DRIFT_LABEL}" &>/dev/null
  if ! launchctl bootstrap "gui/${UID}" "$plist" 2>/dev/null \
    && ! { sleep 1; launchctl bootstrap "gui/${UID}" "$plist"; }; then
    log_error "brew-drift: launchctl could not load ${plist}"
    return 1
  fi
  log_success "brew-drift weekly reminder loaded: ${plist}"
}
