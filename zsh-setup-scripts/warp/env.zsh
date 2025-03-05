#!/bin/zsh
src "$(basename "${(%):-%x}")"

export_n_log WARP_THEMES_DIR="$XDG_CONFIG_HOME/.warp/themes"
