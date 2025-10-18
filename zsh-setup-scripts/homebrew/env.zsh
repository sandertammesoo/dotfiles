#!/usr/bin/env zsh

# Detect Homebrew installation (supports both Intel and Apple Silicon Macs)
BREW_PATH=""

if command -v brew &> /dev/null; then
    # Already in PATH
    BREW_PATH="$(command -v brew)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon Mac
    BREW_PATH="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    # Intel Mac
    BREW_PATH="/usr/local/bin/brew"
else
    log_warn "Homebrew not found, skipping Homebrew shell integration"
    return
fi

log_success "Homebrew is installed at $BREW_PATH, setting up shell integration"

if eval "$($BREW_PATH shellenv zsh)"; then
    if command -v brew &> /dev/null; then
        # Set up Homebrew environment for zsh
        # export HOMEBREW_NO_ANALYTICS=1 # disable analytics
        # export HOMEBREW_NO_ENV_HINTS=1  # disable env hints
        # export HOMEBREW_AUTO_UPDATE_SECS=86400 # 24 hours
        # export HOMEBREW_NO_INSTALL_CLEANUP=1 # disable auto cleanup
        export_n_log HOMEBREW_NO_EMOJI=1 # disable emoji in output
        export_n_log HOMEBREW_NO_AUTO_UPDATE=1 # disable auto update before commands
        log_success "Homebrew environment configured successfully"
    else
        log_failure "Failed to configure Homebrew environment"  
    fi
else
    log_failure "Failed to evaluate Homebrew shellenv"
fi
