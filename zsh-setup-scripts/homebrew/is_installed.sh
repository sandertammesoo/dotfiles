#!/usr/bin/env zsh

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  log_warn "Homebrew not installed. Installing now..."
  
  # Install Homebrew based on OS
  case "$(uname -s)" in
    Darwin|Linux)  
      log_info "Installing Homebrew for $(uname -s)..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
        log_success "Homebrew install successful" || {
        log_fatal "Installation failed: Homebrew installation script returned an error."
        return 1
      }
      ;;
    *)  
      log_fatal "Installation failed: Unsupported OS ($(uname -s))"
      return 1
      ;;
  esac
else
  log_verbose "Homebrew already installed. Skipping installation."
fi


# Set up Homebrew environment for zsh base on detected installation path and OS
BREW_PATH=""
if command -v brew &> /dev/null; then
    # Already in PATH
    BREW_PATH="$(command -v brew)"
else
  case "$(uname -s)" in
      Darwin)
          if [[ -x "/opt/homebrew/bin/brew" ]]; then
              BREW_PATH="/opt/homebrew/bin/brew"
          elif [[ -x "/usr/local/bin/brew" ]]; then
              BREW_PATH="/usr/local/bin/brew"
          else
              log_fatal "Homebrew installation not found after installation attempt!"
              return 1
          fi
          ;;
      Linux)
          if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
              BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
          else
              log_fatal "Homebrew installation not found after installation attempt!"
              return 1
          fi
          ;;
      *)
          log_fatal "Unsupported OS ($(uname -s)) for Homebrew environment setup!"
          return 1
          ;;
  esac
fi

if eval "$($BREW_PATH shellenv zsh)"; then
    log_verbose "Homebrew shell environment setup successful"
else
    log_fatal "Homebrew shell environment setup failed"
    return 1
fi

return 0