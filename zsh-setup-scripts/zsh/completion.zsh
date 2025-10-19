#!/usr/bin/env zsh

# matches case insensitive for lowercase
if zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'; then
    log_debug "Case-insensitive completion matching set up successfully"
else
    log_warn "Failed to set up case-insensitive completion matching"
fi

# pasting with tabs doesn't perform completion
if zstyle ':completion:*' insert-tab pending; then
    log_debug "Tab key behavior for completion set up successfully"
else
    log_warn "Failed to set up Tab key behavior for completion"
fi

try 'zsh-users/zsh-completions' && {
    log_debug "zsh-completions plugin loaded successfully"
} || log_warn "Failed to load zsh-completions plugin"