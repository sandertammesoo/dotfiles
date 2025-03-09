#!/usr/bin/env zsh
src "$(basename "${(%):-%x}")"

# Homebrew Installation & Package Management

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  if ! command -v /opt/homebrew/bin/brew &>/dev/null; then
    warn " ! Homebrew not installed. Installing now..."
    
    # Install Homebrew based on OS
    case "$(uname -s)" in
      Darwin|Linux)  
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
          success "  ✓ Homebrew install successful" || {
          fail " ✗ Installation failed: Homebrew installation script returned an error."
          exit 1
        }
        ;;
      *)  
        fail " ✗ Installation failed: Unsupported OS ($(uname -s))"
        exit 1
        ;;
    esac
  fi
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# Update Homebrew
user "Updating Homebrew..."
brew update | info_stream && success " ✓ Homebrew updated."

# Install packages from Brewfiles
user "Installing Homebrew packages..."
for brewfile in ./brewfiles/*.Brewfile; do
  info "  › Installing from $(basename "$brewfile")..."
  brew bundle --file="$brewfile" 2>&1 | info_stream && success "  ✓ $(basename "$brewfile") installed."
done

# Cleanup
user "Running Homebrew upgrade..."
brew upgrade | info_stream && success " ✓ Homebrew upgrade complete."

# Cleanup
user "Running Homebrew cleanup..."
brew cleanup | info_stream && success " ✓ Homebrew cleanup complete."

# Doctor
user "Running Homebrew doctor..."
brew doctor | info_stream && success " ✓ Homebrew doctor complete."

success " ✓ Homebrew setup finished!"
exit 0
