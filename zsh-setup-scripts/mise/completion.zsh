#!/usr/bin/env zsh

if command -v mise &> /dev/null; then
    log_success "mise is installed, setting up completions"
    if source <(mise completion zsh) 2>/dev/null; then
        log_success "mise completions configured successfully"
    else
        log_failure "Failed to initialize mise completions"
    fi
else
    log_skip "mise not found, skipping mise completions"
fi
