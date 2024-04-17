#!/bin/zsh

if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
else
    warn "Could not find fzf. fzf is not installed?"
fi
