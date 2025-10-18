#!/usr/bin/env zsh

# matches case insensitive for lowercase
log_verbose " > Setting up completion styles"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
log_verbose " > Setting up tab key behavior for completion"
zstyle ':completion:*' insert-tab pending
