#!/usr/bin/env zsh

if command -v wt &> /dev/null; then
    log_success "wt is installed, setting up shell integration"
    # Run eval "$(command wt config shell init zsh)" to initialize wt's shell integration
    if eval "$(command wt config shell init zsh)" 2>/dev/null; then
        log_success "wt shell integration configured successfully"
    else
        log_failure "Failed to initialize wt shell integration"
    fi
else
    log_skip "wt not found, skipping wt shell integration"
fi