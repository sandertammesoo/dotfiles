#!/bin/zsh
src "$(basename "${(%):-%x}")"
# GRC colorizes nifty unix tools all over the place

# Check if 'grc' is NOT available
if (( ! $+commands[grc] )); then
    warn " ! 'grc' is not installed."
    return
fi

# Check if 'brew' is NOT available
if (( ! $+commands[brew] )); then
    warn " ! 'brew' is not installed."
    return
fi

if (( $+commands[grc] )) && (( $+commands[brew] ))
then
    try_source `brew --prefix`/etc/grc.zsh
    # if [ -f `brew --prefix`/etc/grc.zsh ]
    # then
    #     source `brew --prefix`/etc/grc.zsh
    # else
    #     fail '  Could not find grc.zsh from '`brew --prefix`'/etc/...'
    # fi
fi
