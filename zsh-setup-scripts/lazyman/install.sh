#!/bin/zsh
set -e
source helpers.zsh
#
# Lazyman
#
# https://lazyman.dev/about/
#
# The Lazyman project can be used to install, initialize, and manage multiple Neovim configurations.
#

if command -v lazyman >/dev/null; then
  debug "lazyman already installed. Skipping..."
else
  # Check for lazyman submodule
  if [[ -e $XDG_CONFIG_HOME/.dotfiles/git-submodules/nvim-lazyman/lazyman.sh ]]; then
    $XDG_CONFIG_HOME/.dotfiles/git-submodules/nvim-lazyman/lazyman.sh -h -z -Q
  fi
fi

if [ -d $XDG_CONFIG_HOME/nvim-myAstroNvim ]; then
  debug "nvim-myAstroNvim exists. Skipping..."
else
  lazyman -C https://github.com/sandertammesoo/AstroNvim.git -N nvim-myAstroNvim -z -Q
fi
