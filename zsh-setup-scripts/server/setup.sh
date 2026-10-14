#!/usr/bin/env zsh
#
# Server profile steps for ./install-server: an always-on, headless Mac that
# you reach over SSH (Remote Login) and Tailscale.
#
# Each step is a function, is idempotent, and uses log_* for output. The
# file is named setup.sh, not install.sh, so the find in install-all does
# not see it, and not *.zsh, so get_zsh_files does not source it at shell
# start.
#
# Paths come from variables so the specs can point them at a temp dir.

: ${SERVER_SSHD_CONFIG_DIR:=/etc/ssh/sshd_config.d}
: ${SERVER_AUTHORIZED_KEYS:=$HOME/.ssh/authorized_keys}
: ${SERVER_BATTERY_LIMIT:=80}

# Sorts before macOS's 100-macos.conf. sshd keeps the first value it reads
# for a keyword, so this file wins any conflict.
SERVER_SSHD_CONFIG_NAME="050-server.conf"

# sudo resets PATH to secure_path, which has no /opt/homebrew/bin.
_server_sudo() {
  local bin="$(command -v "$1")"
  if [[ -z "$bin" ]]; then
    log_error "$1 not found on PATH"
    return 127
  fi
  shift
  sudo "$bin" "$@"
}

server_sshd_config_content() {
  print -r -- "# Managed by ~/projects/dotfiles/install-server — do not edit here.
# Key-only SSH login. Screen Sharing and sudo still use the account password.
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no"
}

###############################################################################
# server_set_hostname NAME — ComputerName, HostName and LocalHostName.
# LocalHostName is the NAME.local Bonjour name.
###############################################################################
server_set_hostname() {
  local name="$1"
  if [[ -z "$name" ]]; then
    log_skip "No --hostname given; keeping '$(scutil --get LocalHostName 2>/dev/null)'."
    return 0
  fi
  if [[ ! "$name" =~ '^[A-Za-z0-9-]+$' ]]; then
    log_error "Hostname '$name' is not valid: use letters, digits and '-' only."
    return 1
  fi

  local key
  for key in ComputerName HostName LocalHostName; do
    if [[ "$(scutil --get "$key" 2>/dev/null)" == "$name" ]]; then
      log_verbose "$key is already '$name'"
    elif sudo scutil --set "$key" "$name"; then
      log_success "$key set to '$name'"
    else
      log_error "Could not set $key"
      return 1
    fi
  done
}

###############################################################################
# server_configure_power — never sleep, wake on network, panel off after 1 min.
###############################################################################
server_configure_power() {
  local -a settings=(sleep 0 disksleep 0 displaysleep 1 powernap 0 womp 1 tcpkeepalive 1)

  # MacBooks do not list autorestart: the battery bridges a power cut, and
  # Apple Silicon laptops boot when power returns after a full drain.
  if pmset -g cap 2>/dev/null | grep -qw autorestart; then
    settings+=(autorestart 1)
  fi

  if ! sudo pmset -a "${settings[@]}"; then
    log_error "pmset could not apply: ${settings[*]}"
    return 1
  fi
  # disablesleep also keeps the Mac awake with the lid closed.
  if ! sudo pmset -a disablesleep 1; then
    log_error "pmset could not apply disablesleep 1"
    return 1
  fi
  log_success "Power: no sleep, lid close ignored, display off after 1 min"
}

###############################################################################
# server_harden_sshd — key-only login through a drop-in sshd config.
#
# Refuses to run without an authorized key, because the result would lock
# out every SSH login. Validates with `sshd -T` and removes the drop-in
# again if the validation fails, before sshd restarts.
###############################################################################
server_harden_sshd() {
  local conf="${SERVER_SSHD_CONFIG_DIR}/${SERVER_SSHD_CONFIG_NAME}"
  local desired="$(server_sshd_config_content)"

  if ! grep -qE '^(ssh-|ecdsa-|sk-)' "$SERVER_AUTHORIZED_KEYS" 2>/dev/null; then
    log_error "No public key in ${SERVER_AUTHORIZED_KEYS}."
    log_error "Key-only login would lock you out. On your main Mac, run:"
    log_error "  ssh-copy-id ${USER}@$(scutil --get LocalHostName 2>/dev/null || hostname -s).local"
    return 1
  fi

  if [[ "$(sudo cat "$conf" 2>/dev/null)" == "$desired" ]]; then
    log_skip "sshd drop-in already current: $conf"
    return 0
  fi

  if ! print -r -- "$desired" | sudo tee "$conf" >/dev/null; then
    log_error "Could not write $conf"
    return 1
  fi

  local effective
  effective="$(sudo sshd -T 2>&1)"
  local expected
  for expected in "passwordauthentication no" "kbdinteractiveauthentication no" "permitrootlogin no"; do
    if ! print -r -- "$effective" | grep -qx "$expected"; then
      log_error "sshd -T does not show '$expected'. Removing $conf; sshd is not restarted."
      sudo rm -f "$conf"
      return 1
    fi
  done

  if sudo launchctl kickstart -k system/com.openssh.sshd; then
    log_success "sshd: key-only login active ($conf)"
    log_info "Open SSH sessions stay connected. Test a new one with: ssh -S none <host> true"
  else
    log_error "sshd restart failed. The drop-in is in place: $conf"
    return 1
  fi
}

###############################################################################
# server_start_root_service FORMULA — run a formula as a boot-time daemon.
###############################################################################
server_start_root_service() {
  setopt localoptions pipefail
  local formula="$1"
  if ! brew list --formula "$formula" &>/dev/null; then
    log_error "$formula is not installed; it is in brewfiles/server.Brewfile"
    return 1
  fi
  if _server_sudo brew services info "$formula" --json 2>/dev/null | grep -q '"running": *true'; then
    log_skip "$formula service already running as root"
    return 0
  fi
  if _server_sudo brew services start "$formula" 2>&1 | output_stream; then
    log_success "$formula service started as root (starts at boot)"
  else
    log_error "Could not start the $formula service"
    return 1
  fi
}

###############################################################################
# server_configure_tailscale — daemon at boot, then sign in once.
###############################################################################
server_configure_tailscale() {
  server_start_root_service tailscale || return 1

  # tailscaled needs a moment to create its socket after a first start.
  local i
  for i in {1..10}; do
    tailscale status &>/dev/null && break
    [[ "$(tailscale status 2>&1)" == *"Logged out"* ]] && break
    sleep 1
  done

  if tailscale status &>/dev/null; then
    log_success "Tailscale connected: $(tailscale ip -4 2>/dev/null | head -1)"
    return 0
  fi

  log_user "Tailscale is not signed in. Open the URL below on your main Mac to approve this machine."
  if _server_sudo tailscale up --timeout=5m; then
    log_success "Tailscale connected: $(tailscale ip -4 2>/dev/null | head -1)"
  else
    log_warn "Tailscale sign-in did not complete. Run 'sudo tailscale up' later."
    return 1
  fi
}

###############################################################################
# server_configure_battery — cap the charge, as the Mac is always on power.
###############################################################################
server_configure_battery() {
  setopt localoptions pipefail
  if ! pmset -g batt 2>/dev/null | grep -q InternalBattery; then
    log_skip "No internal battery; skipping the charge limit"
    return 0
  fi
  server_start_root_service batt || return 1

  local i
  for i in {1..10}; do
    _server_sudo batt status &>/dev/null && break
    sleep 1
  done

  if _server_sudo batt limit "$SERVER_BATTERY_LIMIT" 2>&1 | output_stream; then
    log_success "Battery charge limited to ${SERVER_BATTERY_LIMIT}%"
  else
    log_error "batt could not set the limit to ${SERVER_BATTERY_LIMIT}%"
    return 1
  fi
}
