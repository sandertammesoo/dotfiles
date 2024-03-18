#!/bin/zsh
# GRC colorizes nifty unix tools all over the place

# Check if 'grc' is NOT available
if (( ! $+commands[grc] )); then
    warn "'grc' is not installed."
    return
fi

# Check if 'brew' is NOT available
if (( ! $+commands[brew] )); then
    warn "'brew' is not installed."
    return
fi

if (( $+commands[grc] )) && (( $+commands[brew] ))
then
  source `brew --prefix`/etc/grc.bashrc
  info "test"
fi
