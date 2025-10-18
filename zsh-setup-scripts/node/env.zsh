#!/usr/bin/env zsh

if command -v node &> /dev/null || command -v npm &> /dev/null; then
    log_success "Node.js found, setting up XDG-compliant environment"
    
    # Node.js XDG configuration
    export_n_log NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"
    export_n_log NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
    export_n_log NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
    export_n_log NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
    
    # Add npm global bin to PATH
    add_to PATH "$XDG_DATA_HOME/npm/bin"
else
    log_info " !  Node.js not found, skipping Node.js environment setup"
fi