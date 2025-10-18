#!/usr/bin/env zsh

# Ensure Homebrew is installed
if ! command -v /opt/homebrew/bin/brew &>/dev/null; then
  log_warn "Homebrew not installed. Installing now..."
  
  # Install Homebrew based on OS
  case "$(uname -s)" in
    Darwin|Linux)  
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
        log_success "Homebrew install successful" || {
        log_failure "Installation failed: Homebrew installation script returned an error."
        return 1
      }
      ;;
    *)  
      log_failure "Installation failed: Unsupported OS ($(uname -s))"
      return 1
      ;;
  esac
else
  log_success "Homebrew already installed. Skipping installation."
fi

if eval "$(/opt/homebrew/bin/brew shellenv zsh)"; then
    log_success "Homebrew shell environment setup successful"
else
    log_failure "Homebrew shell environment setup failed"
    return 1
fi

return 0