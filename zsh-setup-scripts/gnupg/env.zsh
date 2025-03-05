#!/bin/zsh
src "$(basename "${(%):-%x}")"

export_n_log GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export_n_log GPG_TTY=$(tty)
