#!/usr/bin/env zsh

# Source helper functions for logging and miscellaneous utilities
# Try to source from the home directory first, then fallback to the current directory
if [[ -f "$HOME/.config/.dotfiles/helpers_logging.zsh" ]]; then
  source "$HOME/.config/.dotfiles/helpers_logging.zsh"
else
  source "./helpers_logging.zsh"
fi

if [[ -f "$HOME/.config/.dotfiles/helpers_misc.zsh" ]]; then
  source "$HOME/.config/.dotfiles/helpers_misc.zsh"
else
  source "./helpers_misc.zsh"
fi
