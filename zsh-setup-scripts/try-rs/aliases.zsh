#!/usr/bin/env zsh

if command -v try-rs &> /dev/null; then
    log_success "try-rs is installed, setting up aliases"

    # Expands to the try-rs shell function from completion.zsh, which evals
    # the `cd` the binary prints. The alias resolves at use time, so it does
    # not matter that the function is defined later in startup.
    alias try='try-rs'
else
    log_skip "try-rs not found, skipping try-rs aliases"
fi
