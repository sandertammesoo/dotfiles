#!/usr/bin/env zsh

if command -v ngrok &>/dev/null; then
    log_success "ngrok found, setting up ngrok completion"
    if eval "$(ngrok completion)" 2>/dev/null; then
        log_success "ngrok completion setup successful"
    else
        log_failure "ngrok completion setup failed"
    fi
else
    log_warn "ngrok not found, skipping ngrok completion setup"
fi
