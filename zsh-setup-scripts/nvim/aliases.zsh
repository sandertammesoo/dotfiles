#!/usr/bin/env zsh

if command -v nvim &> /dev/null; then
    log_success "Neovim is installed, setting up aliases"
    
    # Shortcuts
    alias n="nvim"
    alias vi="nvim"
    alias vim="nvim"
    alias vimdiff="nvim -d"
    alias svi="sudo nvim"
    alias sviu="sudo nvim -u NONE"
    alias nv="nvim"
    # alias nvr="nvr --remote-tab" # requires neovim-remote (brew install neovim-remote)
    # alias nvs="nvr --remote-send '<C-\><C-n>'" # requires neovim-remote (brew install neovim-remote)
else
    log_warn "Neovim not found, skipping Neovim aliases"
    return
fi

