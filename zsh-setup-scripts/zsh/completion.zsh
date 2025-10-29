#!/usr/bin/env zsh

# matches case insensitive for lowercase
if zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'; then
    log_debug "Case-insensitive completion matching set up successfully"
else
    log_warn "Failed to set up case-insensitive completion matching"
fi

# pasting with tabs doesn't perform completion
if zstyle ':completion:*' insert-tab pending; then
    log_debug "Tab key behavior for completion set up successfully"
else
    log_warn "Failed to set up Tab key behavior for completion"
fi

################################################################################
# _rebuild_completion_cache: Safely rebuild the zsh completion cache with 
# concurrent access protection. Uses a lock file mechanism to prevent multiple
# zsh sessions from interfering with each other during cache rebuilds.
# 
# This function is particularly important after loading new completion sources
# (like zoxide) that require the completion cache to be rebuilt.
#
# Usage: _rebuild_completion_cache
# Examples:
#   _rebuild_completion_cache  # Rebuild the completion cache safely
################################################################################
_rebuild_completion_cache() {
    local lockfile="$XDG_CONFIG_HOME/.zcompdump.lock"
    local max_wait=5
    local waited=0
    
    # Wait for any existing rebuild to complete
    while [[ -f "$lockfile" && $waited -lt $max_wait ]]; do
        sleep 0.1
        ((waited++))
    done
    
    # If we waited too long, remove stale lock
    if [[ $waited -ge $max_wait && -f "$lockfile" ]]; then
        log_debug "Removing stale completion cache lock file"
        rm -f "$lockfile"
    fi
    
    # Create lock file with PID to prevent concurrent rebuilds
    echo $$ > "$lockfile" 2>/dev/null || return 1
    
    # Rebuild completions with error handling
    if rm -f "$XDG_CONFIG_HOME/.zcompdump"* 2>/dev/null && compinit -d "$XDG_CONFIG_HOME/.zcompdump" -C -u 2>/dev/null; then
        log_success "Completion cache rebuilt successfully"
    else
        log_warn "Completion cache rebuild failed or already in progress, using existing cache"
    fi
    
    # Remove lock file
    rm -f "$lockfile" 2>/dev/null
}