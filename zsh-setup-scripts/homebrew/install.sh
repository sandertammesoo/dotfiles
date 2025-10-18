#!/usr/bin/env zsh

# Homebrew Installation & Package Management

# Ensure Homebrew is installed
if source zsh-setup-scripts/homebrew/is_installed.sh; then
  log_success "Homebrew is installed"
else
  log_failure "Homebrew installation failed. Please check the logs above."
  return 1
fi

# Update Homebrew
log_user "Updating Homebrew..."
if brew update 2>&1 | output_stream; then
  log_success "Homebrew updated."
else
  log_failure "Homebrew update failed."
  return 1
fi

# Install packages from Brewfiles
log_user "Installing Homebrew packages from $(basename "./brewfiles/Brewfile")..."
if brew bundle --file="./brewfiles/Brewfile" 2>&1 | output_stream; then
  log_success "Brewfile packages installed."
else
  log_failure "Brewfile package installation failed."
  return 1
fi

# Upgrade installed packages
log_user "Running Homebrew upgrade..."
if brew upgrade 2>&1 | output_stream; then
  log_success "Homebrew upgrade complete."
else
  log_failure "Homebrew upgrade failed."
  return 1
fi

# Cleanup
log_user "Running Homebrew cleanup..."
if brew cleanup 2>&1 | output_stream; then
  log_success "Homebrew cleanup complete."
else
  log_failure "Homebrew cleanup failed."
  return 1
fi

# Doctor
log_user "Running Homebrew doctor..."
if brew doctor 2>&1 | output_stream; then
  log_success "Homebrew doctor complete."
else
  log_warn "Homebrew doctor found issues (this is often non-critical)."
fi

log_success "Homebrew setup finished!"
return 0