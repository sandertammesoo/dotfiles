#!/bin/zsh
src "$(basename "${(%):-%x}")"

export_n_log CHEAT_CONFIG_PATH="$XDG_CONFIG_HOME/.cheat/conf.yml"
export_n_log CHEAT_USE_FZF=true
