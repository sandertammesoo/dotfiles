#!/bin/zsh

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    #eval "$(zoxide init --cmd cd zsh)"
else
    warn "Could not find ngrok. ngrok is not installed?"
fi