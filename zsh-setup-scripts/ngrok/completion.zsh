#!/bin/zsh

if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
else
    warn "Could not find ngrok. ngrok is not installed?"
fi