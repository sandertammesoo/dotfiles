#!/usr/bin/env zsh
# GRC colorizes nifty unix tools all over the place

# Check if 'grc' is NOT available
if ! command -v grc &> /dev/null; then
    log_skip "grc not found, skipping grc shell integration"
    return
fi

# Check if 'brew' is NOT available
if ! command -v brew &> /dev/null; then
    log_skip "brew not found, skipping grc shell integration"
    return
fi

if command -v grc &> /dev/null && command -v brew &> /dev/null; then
    log_success "grc is installed, setting up grc shell integration"
    try_source `brew --prefix`/etc/grc.zsh
fi
