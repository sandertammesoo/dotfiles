#!/usr/bin/env zsh

# Lazyman - A tool for managing multiple Neovim configurations
# https://lazyman.dev/about/


# Check if Lazyman installation should be skipped
if (( ${SETUP_LAZYMAN:-0} == 0 )); then
  log_skip "Skipping Lazyman installation for now, as it's not fully ready yet."
  return 0
fi

log_user "Checking Lazyman installation..."
if command -v lazyman > /dev/null; then
  log_success "Lazyman is already installed. Skipping installation."
else
  log_debug "Check if the Lazyman submodule exists before attempting installation"
  LAZYMAN_SCRIPT="$XDG_CONFIG_HOME/.dotfiles/git-submodules/nvim-lazyman/lazyman.sh"
  
  if [[ -x "$LAZYMAN_SCRIPT" ]]; then
    log_info "Installing Lazyman from submodule..."
    log_debug "Running: $LAZYMAN_SCRIPT -h -z -Q -n"  # -n for dry run;
    if "$LAZYMAN_SCRIPT" -h -z -Q -n; then # -n for dry run;
      log_success "Lazyman installed successfully."
    else
      log_fatal "Failed to install Lazyman."
      return 1
    fi
  else
    log_warn "Lazyman submodule not found. Skipping installation."
    return 1
  fi
fi

log_user "Checking nvim-myAstroNvim configuration..."

NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim-myAstroNvim"

if [[ -d "$NVIM_CONFIG_DIR" ]]; then
  log_success "nvim-myAstroNvim already exists. Skipping setup."
else
  log_info "Cloning AstroNvim configuration..."
  if lazyman -C "https://github.com/sandertammesoo/AstroNvim.git" -N "nvim-myAstroNvim" -z -Q -n; then # -n for dry run; TODO: Remove -n when ready
    log_success "nvim-myAstroNvim installed successfully."
  else
    log_fatal "Failed to install nvim-myAstroNvim."
    return 1
  fi
fi
