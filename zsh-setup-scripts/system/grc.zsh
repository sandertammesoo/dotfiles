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
    if [ -f `brew --prefix`/etc/grc.zsh ]
    then
        source `brew --prefix`/etc/grc.zsh
        log_info '  Loaded GRC conf'
    else
        fail '  Could not find grc.zsh from '`brew --prefix`'/etc/...'
    fi
fi
