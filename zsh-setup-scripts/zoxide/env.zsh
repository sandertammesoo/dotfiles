#!/bin/zsh
src "$(basename "${(%):-%x}")"

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
    # If you want to override `cd`, you can uncomment the line below
    # eval "$(zoxide init --cmd cd zsh)"
else
    warn " ! Could not find zoxide. Is it installed?"
fi
