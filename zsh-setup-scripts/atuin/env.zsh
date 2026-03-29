#!/usr/bin/env zsh

if command -v atuin &> /dev/null; then
    log_success "atuin is installed, setting up shell integration"
    if eval "$(atuin init zsh)" 2>/dev/null; then
        log_success "atuin shell integration configured successfully"
    else
        log_failure "Failed to initialize atuin shell integration"
    fi
else
    log_skip "atuin not found, skipping atuin shell integration"
fi
