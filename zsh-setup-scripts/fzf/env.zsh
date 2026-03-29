#!/usr/bin/env zsh

if command -v fzf &> /dev/null; then
    log_success "fzf is installed, setting up shell integration"
    if source <(fzf --zsh) 2>/dev/null; then
        log_success "fzf shell integration configured successfully"

        export FZF_DEFAULT_OPTS="
            --color=bg:#1a1b26,bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5
            --color=hl:#7aa2f7,hl+:#7aa2f7,border:#414868
            --color=prompt:#7aa2f7,pointer:#7aa2f7,marker:#9ece6a,info:#9ece6a"
    else
        log_failure "Failed to initialize fzf shell integration"
    fi
else
    log_skip "fzf not found, skipping fzf shell integration"
fi
