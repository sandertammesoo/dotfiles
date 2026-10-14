# shellcheck shell=zsh
# ShellSpec tests for the brew-drift integration (zsh-setup-scripts/brew-drift).
#
# The installers write the local config and the weekly reminder without the
# brew-drift binary. The reminder runs `brew-drift status` from launchd. The
# tests use a temp XDG_CONFIG_HOME, a temp LaunchAgents directory, and stub
# brew-drift, launchctl and osascript commands on PATH.

Describe 'brew-drift integration (brew-drift/setup.sh)'
  setup() {
    REPO_ROOT="$PWD"
    TEST_DIR="$(mktemp -d)"
    CALLS="${TEST_DIR}/calls"
    : > "$CALLS"

    export LOG_LEVEL="ERROR" LOG_ENABLED=true LOG_COLOR=never
    source "${REPO_ROOT}/helpers_logging.zsh"

    ORIG_XDG_CONFIG_HOME="${XDG_CONFIG_HOME-}"
    ORIG_XDG_STATE_HOME="${XDG_STATE_HOME-}"
    export XDG_CONFIG_HOME="${TEST_DIR}/config"
    export XDG_STATE_HOME="${TEST_DIR}/state"
    export BREW_DRIFT_LAUNCH_AGENTS_DIR="${TEST_DIR}/LaunchAgents"
    source "${REPO_ROOT}/zsh-setup-scripts/brew-drift/setup.sh"
    LOCAL_CONFIG="${XDG_CONFIG_HOME}/brew-drift/config.toml"
    PLIST="${BREW_DRIFT_LAUNCH_AGENTS_DIR}/${BREW_DRIFT_LABEL}.plist"

    # STUB_STATUS: the exit status of the stub `brew-drift status`.
    export STUB_STATUS=0
    local bin="${TEST_DIR}/bin"
    mkdir -p "$bin"
    printf '#!/bin/sh\necho "brew-drift $*" >> "%s"\necho "untracked: wget"\nexit "$STUB_STATUS"\n' "$CALLS" > "$bin/brew-drift"
    # STUB_NO_GUI=true: `launchctl print gui/<uid>` fails, as in an SSH session.
    printf '#!/bin/sh\necho "launchctl $*" >> "%s"\n[ "$1" = print ] && [ "${STUB_NO_GUI:-false}" = true ] && exit 113\nexit 0\n' "$CALLS" > "$bin/launchctl"
    printf '#!/bin/sh\necho "osascript $*" >> "%s"\n' "$CALLS" > "$bin/osascript"
    chmod +x "$bin"/*
    BIN="$bin"
    ORIG_PATH="$PATH"
    export PATH="${bin}:${PATH}"
    rehash
  }

  cleanup() {
    export PATH="$ORIG_PATH"
    export XDG_CONFIG_HOME="$ORIG_XDG_CONFIG_HOME" XDG_STATE_HOME="$ORIG_XDG_STATE_HOME"
    rehash
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'the repo config (brewfiles/brew-drift.toml)'
    It 'names the mac and server profiles, and each Brewfile exists'
      The contents of file "brewfiles/brew-drift.toml" should include 'mac = ["Brewfile"]'
      The contents of file "brewfiles/brew-drift.toml" should include 'server = ["server.Brewfile"]'
      The path "brewfiles/Brewfile" should be file
      The path "brewfiles/server.Brewfile" should be file
    End
  End

  Describe 'brew_drift_write_local_config'
    It 'writes the profile and the absolute path of the repo config'
      When call brew_drift_write_local_config mac
      The status should be success
      The contents of file "$LOCAL_CONFIG" should include 'profile = "mac"'
      The contents of file "$LOCAL_CONFIG" should include "repo = \"${REPO_ROOT}/brewfiles/brew-drift.toml\""
    End

    It 'writes the server profile'
      When call brew_drift_write_local_config server
      The status should be success
      The contents of file "$LOCAL_CONFIG" should include 'profile = "server"'
    End

    It 'does not overwrite a local config that exists'
      mkdir -p "${LOCAL_CONFIG:h}"
      printf 'profile = "mine"\n' > "$LOCAL_CONFIG"
      When call brew_drift_write_local_config mac
      The status should be success
      The contents of file "$LOCAL_CONFIG" should equal 'profile = "mine"'
    End

    It 'refuses a profile that the repo config does not have'
      When call brew_drift_write_local_config laptop
      The status should be failure
      The stderr should include "laptop"
      The path "$LOCAL_CONFIG" should not be exist
    End
  End

  Describe 'brew_drift_install_reminder'
    It 'writes a weekly launchd agent that runs the reminder script'
      When call brew_drift_install_reminder
      The status should be success
      The contents of file "$PLIST" should include "<string>${BREW_DRIFT_LABEL}</string>"
      The contents of file "$PLIST" should include "${REPO_ROOT}/zsh-setup-scripts/brew-drift/reminder.sh"
      The contents of file "$PLIST" should include '<key>Weekday</key>'
      The contents of file "$PLIST" should not include 'RunAtLoad'
    End

    It 'loads the agent again, so a changed plist takes effect'
      When call brew_drift_install_reminder
      The status should be success
      The contents of file "$CALLS" should include "launchctl bootout gui/${UID}/${BREW_DRIFT_LABEL}"
      The contents of file "$CALLS" should include "launchctl bootstrap gui/${UID} ${PLIST}"
    End

    It 'writes the plist but does not load it without a GUI session'
      export STUB_NO_GUI=true
      When call brew_drift_install_reminder
      The status should be success
      The path "$PLIST" should be file
      The contents of file "$CALLS" should not include "bootstrap"
    End
  End

  Describe 'reminder.sh'
    run_reminder() { zsh "${REPO_ROOT}/zsh-setup-scripts/brew-drift/reminder.sh"; }

    It 'is silent when there is no drift'
      When run run_reminder
      The status should be success
      The contents of file "$CALLS" should include "brew-drift status"
      The contents of file "$CALLS" should not include "osascript"
    End

    It 'saves the report and shows a notification when there is drift'
      export STUB_STATUS=1
      When run run_reminder
      The status should be success
      The contents of file "$CALLS" should include "osascript"
      The contents of file "$CALLS" should include "brew-drift fix"
      The contents of file "${XDG_STATE_HOME}/brew-drift/status.txt" should include "untracked: wget"
    End

    It 'shows a notification when brew-drift fails'
      export STUB_STATUS=2
      When run run_reminder
      The status should be failure
      The stderr should include "brew-drift status failed"
      The contents of file "$CALLS" should include "osascript"
    End

    It 'shows a notification when brew-drift is not installed'
      rm "${BIN}/brew-drift"
      export BREW_DRIFT_BIN="${TEST_DIR}/missing/brew-drift"
      When run run_reminder
      The status should be failure
      The stderr should include "not installed"
      The contents of file "$CALLS" should include "osascript"
    End
  End
End
