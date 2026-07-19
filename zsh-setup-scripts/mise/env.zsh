#!/usr/bin/env zsh

# MISE_CACHE_DIR and the shims PATH fallback live in .zshenv so that
# non-interactive shells (scripts, IDEs) resolve mise-managed tools too.
# This module only wires up the interactive activation hook.

if command -v mise &> /dev/null; then
    log_success "mise is installed, setting up shell integration"
    if eval "$(mise activate zsh)" 2>/dev/null; then
        log_success "mise shell activation configured successfully"
    else
        log_failure "Failed to initialize mise shell activation"
    fi
else
    log_skip "mise not found, skipping mise shell integration"
fi
