#!/usr/bin/env zsh
# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).

# Check if 'git' is NOT available
if ! command -v git &> /dev/null; then
    log_warn "git not found, skipping git completion setup"
    return
fi

if ! command -v brew &> /dev/null; then
    log_warn "brew not found, skipping git completion setup"
    return
fi

# Add Homebrew completion directory to fpath
completion_path="$(brew --prefix)/share/zsh/site-functions"
if [[ -d "$completion_path" ]]; then
    fpath=("$completion_path" $fpath)
    log_success "Added Homebrew completions to fpath: $completion_path"
else
    # Try fallback paths
    for path in "/usr/local/share/zsh/site-functions" "/usr/share/zsh/site-functions"; do
        if [[ -d "$path" ]]; then
            fpath=("$path" $fpath)
            log_success "Added completions to fpath: $path"
            break
        fi
    done
fi
