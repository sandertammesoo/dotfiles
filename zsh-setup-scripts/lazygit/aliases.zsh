#!/usr/bin/env zsh

if command -v lazygit &> /dev/null; then
    log_success "Lazygit is installed, setting up aliases"

    # Shortcuts
    alias lazygit="lazygit -ucd $XDG_CONFIG_HOME/lazygit/"

else
    log_info " !  Lazygit not found, skipping Lazygit aliases"
    return
fi



