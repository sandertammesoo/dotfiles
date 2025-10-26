#!/usr/bin/env zsh

if command -v nvim &> /dev/null; then
    log_success "nvim is installed, setting up nvim environment"
    if [[ -d $XDG_CONFIG_HOME/nvim-myAstroNvim ]]; then
        log_info "nvim-myAstroNvim config found, using nvim-myAstroNvim config"
        export_n_log NVIM_APPNAME=nvim-myAstroNvim
    else
        log_info "nvim-myAstroNvim config not found, using default nvim config"
        export_n_log NVIM_APPNAME=nvim
    fi
else
    log_skip "nvim not found, skipping nvim environment setup"
fi

