#!/usr/bin/env zsh

if command -v wt &> /dev/null; then
    log_success "wt (worktrunk) is installed, setting up aliases"
    
    
    # wsc new-feature                       # Creates worktree, runs hooks, launches Claude
    # wsc feature -- 'Fix GH #322'          # Runs `claude 'Fix GH #322'`
    alias wsc='wt switch --create --execute=claude'


else
    log_skip "worktrunk not found, skipping Git aliases"
    return
fi



