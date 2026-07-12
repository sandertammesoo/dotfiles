#!/usr/bin/env zsh

if command -v fnm &> /dev/null; then
    log_success "fnm is installed, setting up shell integration"
    if source <(fnm env --use-on-cd) 2>/dev/null; then
        log_success "fnm shell integration configured successfully"
    else
        log_failure "Failed to initialize fnm shell integration"
    fi
else
    log_skip "fnm not found, skipping fnm shell integration"
fi
