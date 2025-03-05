#!/usr/bin/env zsh
src "$(basename "${(%):-%x}")"

# Lazyman - A tool for managing multiple Neovim configurations
# https://lazyman.dev/about/

user "Checking Lazyman installation..."

if command -v lazyman > /dev/null; then
  success " ✓ Lazyman is already installed. Skipping installation."
else
  # Check if the Lazyman submodule exists before attempting installation
  LAZYMAN_SCRIPT="$XDG_CONFIG_HOME/.dotfiles/git-submodules/nvim-lazyman/lazyman.sh"
  
  if [[ -x "$LAZYMAN_SCRIPT" ]]; then
    info "Installing Lazyman from submodule..."
    "$LAZYMAN_SCRIPT" -h -z -Q
    success " ✓ Lazyman installed successfully."
  else
    warn " ! Lazyman submodule not found. Skipping installation."
  fi
fi

user "Checking nvim-myAstroNvim configuration..."

NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim-myAstroNvim"

if [[ -d "$NVIM_CONFIG_DIR" ]]; then
  success " ✓ nvim-myAstroNvim already exists. Skipping setup."
else
  info "Cloning AstroNvim configuration..."
  if lazyman -C "https://github.com/sandertammesoo/AstroNvim.git" -N "nvim-myAstroNvim" -z -Q; then
    success " ✓ nvim-myAstroNvim installed successfully."
  else
    fail " ✗ Failed to install nvim-myAstroNvim."
  fi
fi
