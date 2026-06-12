#!/usr/bin/env zsh

# Homebrew Installation & Package Management

# Ensure Homebrew is installed
if source zsh-setup-scripts/homebrew/is_installed.sh; then
  log_success "Homebrew is installed"
else
  log_fatal "Homebrew installation failed. Please check the logs above."
  return 1
fi

# Homebrew 6.0+ refuses to load formulae/casks from untrusted non-official taps
# (HOMEBREW_REQUIRE_TAP_TRUST became the default). Pre-trust the taps declared in the
# Brewfile so the upgrade, bundle, and service-bootstrap steps below can load them —
# keeping the security model intact (explicit allowlist) instead of disabling it.
# Runs unconditionally (even with --skip-app-installation) since the bootstraps still run.
brew_trust_brewfile_taps "./brewfiles/Brewfile"

# If SKIP_BREW_UPGRADES or SKIP_UPDATES is set, skip updates and upgrades
if [[ "${SKIP_BREW_UPGRADES:-false}" == "true" ]] || [[ "${SKIP_UPDATES:-false}" == "true" ]]; then
  log_skip "Skipping Homebrew updates and upgrades."
else
  # Update Homebrew
  log_user "Updating Homebrew..."
  if brew update 2>&1 | output_stream; then
    log_success "Homebrew updated."
  else
    log_fatal "Homebrew update failed."
    return 1
  fi

  # Upgrade installed packages
  log_user "Running Homebrew upgrade..."
  if brew upgrade 2>&1 | output_stream; then
    log_success "Homebrew upgrade complete."
  else
    log_fatal "Homebrew upgrade failed."
    return 1
  fi
fi

if [[ "${SKIP_APP_INSTALLATION:-false}" == "true" ]] || [[ "${SKIP_UPDATES:-false}" == "true" ]]; then
  log_skip "Skipping Homebrew package installation."
else
  # Install packages from Brewfiles
  log_user "Installing Homebrew packages from $(basename "./brewfiles/Brewfile")..."
  if brew bundle --file="./brewfiles/Brewfile" 2>&1 | output_stream; then
    log_success "Brewfile packages installed."
  else
    log_fatal "Brewfile package installation failed."
    return 1
  fi
fi

# If neither upgrades nor app installation were skipped, run cleanup and doctor
if [[ "${SKIP_UPDATES:-false}" == "true" ]] || [[ "${SKIP_BREW_UPGRADES:-false}" == "true" && "${SKIP_APP_INSTALLATION:-false}" == "true" ]]; then
  log_skip "Skipping Homebrew cleanup and doctor."
else
  # Cleanup
  log_user "Running Homebrew cleanup..."
  if brew cleanup 2>&1 | output_stream; then
    log_success "Homebrew cleanup complete."
  else
    log_fatal "Homebrew cleanup failed."
    return 1
  fi

  # Doctor
  log_user "Running Homebrew doctor..."
  if brew doctor 2>&1 | output_stream WARN; then
    log_success "Homebrew doctor complete."
  else
    log_warn "Homebrew doctor found issues (this is often non-critical)."
  fi
fi

return 0