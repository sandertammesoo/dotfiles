#!/usr/bin/env zsh
# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).

# Check if 'git' is NOT available
if ! command -v git &> /dev/null; then
    log_skip "git not found, skipping git completion setup"
    return
fi

if ! command -v brew &> /dev/null; then
    log_skip "brew not found, skipping git completion setup"
    return
fi

# Note: Homebrew completion directory is now added to fpath in fpath.zsh 
# (before compinit is called) to ensure proper timing
log_success "Git completions available via Homebrew fpath setup"
