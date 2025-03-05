#!/bin/zsh
src "$(basename "${(%):-%x}")"

if (( $+commands[fzf] )); then
    source <(fzf --zsh)
else
    warn " ! Could not find fzf. Is it installed?"
fi
