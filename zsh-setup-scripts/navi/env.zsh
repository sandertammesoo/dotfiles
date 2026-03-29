#!/usr/bin/env zsh

if command -v navi &> /dev/null; then
    log_success "navi is installed, setting up shell integration"
    # Run eval "$(navi widget zsh)" to initialize navi's shell integration
    if eval "$(navi widget zsh)" 2>/dev/null; then
        log_success "navi shell integration configured successfully"
    else
        log_failure "Failed to initialize navi shell integration"
    fi
else
    log_skip "navi not found, skipping navi shell integration"
fi
