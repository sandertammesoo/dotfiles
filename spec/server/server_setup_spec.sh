# shellcheck shell=zsh
# ShellSpec tests for the server profile steps (zsh-setup-scripts/server/setup.sh).
#
# The step that matters most is server_harden_sshd: a wrong drop-in locks
# every SSH login out of a headless machine. The tests drive it with stub
# sudo, sshd and launchctl commands on PATH and a temp sshd_config.d.

Describe 'server profile steps (server/setup.sh)'
  setup() {
    REPO_ROOT="$PWD"
    TEST_DIR="$(mktemp -d)"
    CALLS="${TEST_DIR}/calls"
    : > "$CALLS"

    export LOG_LEVEL="ERROR" LOG_ENABLED=true LOG_COLOR=never
    source "${REPO_ROOT}/helpers_logging.zsh"
    source "${REPO_ROOT}/helpers_misc.zsh"

    export SERVER_SSHD_CONFIG_DIR="${TEST_DIR}/sshd_config.d"
    export SERVER_AUTHORIZED_KEYS="${TEST_DIR}/authorized_keys"
    mkdir -p "$SERVER_SSHD_CONFIG_DIR"
    source "${REPO_ROOT}/zsh-setup-scripts/server/setup.sh"
    CONF="${SERVER_SSHD_CONFIG_DIR}/050-server.conf"

    # STUB_SSHD_T: what `sshd -T` prints. Default: the hardened values.
    export STUB_SSHD_T="${TEST_DIR}/sshd_t"
    printf 'passwordauthentication no\nkbdinteractiveauthentication no\npermitrootlogin no\n' > "$STUB_SSHD_T"

    local bin="${TEST_DIR}/bin"
    mkdir -p "$bin"
    printf '#!/bin/sh\nexec "$@"\n' > "$bin/sudo"
    printf '#!/bin/sh\ncat "%s"\n' "$STUB_SSHD_T" > "$bin/sshd"
    printf '#!/bin/sh\necho "launchctl $*" >> "%s"\n' "$CALLS" > "$bin/launchctl"
    printf '#!/bin/sh\necho "pmset $*" >> "%s"\n' "$CALLS" > "$bin/pmset"
    printf '#!/bin/sh\n[ "$1" = "--get" ] && echo old-name\necho "scutil $*" >> "%s"\n' "$CALLS" > "$bin/scutil"
    chmod +x "$bin"/*
    ORIG_PATH="$PATH"
    export PATH="${bin}:${PATH}"
    rehash
  }

  cleanup() {
    export PATH="$ORIG_PATH"
    rehash
    rm -rf "$TEST_DIR"
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  Describe 'server_harden_sshd'
    It 'refuses without an authorized key, so it cannot lock you out'
      When call server_harden_sshd
      The status should be failure
      The stderr should include "No public key"
      The file "$CONF" should not be exist
      The contents of file "$CALLS" should not include "kickstart"
    End

    It 'writes the drop-in and restarts sshd when a key exists'
      echo "ssh-ed25519 AAAAdummy test@host" > "$SERVER_AUTHORIZED_KEYS"
      When call server_harden_sshd
      The status should be success
      The contents of file "$CONF" should include "PasswordAuthentication no"
      The contents of file "$CONF" should include "KbdInteractiveAuthentication no"
      The contents of file "$CALLS" should include "kickstart -k system/com.openssh.sshd"
    End

    It 'does not restart sshd when the drop-in is already current'
      echo "ssh-ed25519 AAAAdummy test@host" > "$SERVER_AUTHORIZED_KEYS"
      server_sshd_config_content > "$CONF"
      When call server_harden_sshd
      The status should be success
      The contents of file "$CALLS" should not include "kickstart"
    End

    It 'removes the drop-in and skips the restart when sshd -T disagrees'
      echo "ssh-ed25519 AAAAdummy test@host" > "$SERVER_AUTHORIZED_KEYS"
      printf 'passwordauthentication yes\nkbdinteractiveauthentication no\npermitrootlogin no\n' > "$STUB_SSHD_T"
      When call server_harden_sshd
      The status should be failure
      The stderr should include "passwordauthentication no"
      The file "$CONF" should not be exist
      The contents of file "$CALLS" should not include "kickstart"
    End
  End

  Describe 'server_set_hostname'
    It 'skips when no name is given'
      When call server_set_hostname ""
      The status should be success
      The contents of file "$CALLS" should not include "--set"
    End

    It 'rejects a name that is not a valid Bonjour name'
      When call server_set_hostname "my server"
      The status should be failure
      The stderr should include "not valid"
    End

    It 'sets all three names'
      When call server_set_hostname "jupiter"
      The status should be success
      The contents of file "$CALLS" should include "--set ComputerName jupiter"
      The contents of file "$CALLS" should include "--set HostName jupiter"
      The contents of file "$CALLS" should include "--set LocalHostName jupiter"
    End
  End

  Describe 'server_configure_power'
    It 'disables sleep and does not set autorestart on a MacBook'
      When call server_configure_power
      The status should be success
      The contents of file "$CALLS" should include "pmset -a sleep 0"
      The contents of file "$CALLS" should include "pmset -a disablesleep 1"
      The contents of file "$CALLS" should not include "autorestart"
    End
  End

  Describe 'server_configure_battery'
    It 'skips the charge limit without an internal battery'
      When call server_configure_battery
      The status should be success
      The contents of file "$CALLS" should not include "batt limit"
    End
  End
End
