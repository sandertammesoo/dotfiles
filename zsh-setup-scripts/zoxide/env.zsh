#!/usr/bin/env zsh

if command -v zoxide &> /dev/null; then
    log_success "zoxide is installed, setting up zoxide environment"
    if eval "$(zoxide init zsh)"; then
        log_success "zoxide initialized successfully"
    else
        log_error " ✗  Failed to initialize zoxide"
    fi
    # If you want to override `cd`, you can uncomment the line below
    # eval "$(zoxide init --cmd cd zsh)"
else
    log_skip "zoxide not found, skipping zoxide environment setup"
fi
