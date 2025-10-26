#!/usr/bin/env zsh

if command -v fzf &> /dev/null; then
    log_success "fzf is installed, setting up shell integration"
    if source <(fzf --zsh) 2>/dev/null; then
        log_success "fzf shell integration configured successfully"
    else
        log_failure "Failed to initialize fzf shell integration"
    fi
else
    log_skip "fzf not found, skipping fzf shell integration"
fi
