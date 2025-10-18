#!/usr/bin/env zsh

if [ -d "/Applications/Warp.app" ] || [ -d "$HOME/Applications/Warp.app" ]; then
    log_success "Warp.app found, setting up warp environment"
    # Set Warp environment variables
    export_n_log WARP_DATA_DIR="$XDG_DATA_HOME/.warp"
    export_n_log WARP_CACHE_DIR="$XDG_CACHE_HOME/.warp"
    export_n_log WARP_CONFIG_DIR="$XDG_CONFIG_HOME/.warp"
    export_n_log WARP_THEMES_DIR="$XDG_CONFIG_HOME/.warp/themes"
else
    log_info " !  Warp.app not found, skipping warp environment setup"
fi

