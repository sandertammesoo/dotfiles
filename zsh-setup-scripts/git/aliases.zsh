#!/usr/bin/env zsh

if command -v git &> /dev/null; then
    log_success "Git is installed, setting up aliases"
    
    # Shortcuts
    alias g="git"

    # Basic functions
    alias gpull='git pull'
    alias gpush='git push'
    alias gd='git diff --color | less -R'  # Use git's native color handling
    alias gpr='git pull --rebase'
    alias gpp='git pull --prune'

    # Adding helpers
    alias gadd='git add .'
    alias gcam='git add -A && git commit -m'

    # Logging helpers
    alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

    alias gc='git commit'
    alias gca='git commit -a'
    alias gco='git checkout'
    alias gcb='git copy-branch-name'
    alias gb='git branch'
    alias gs='git status' # upgrade your git if -sb breaks for you. it's fun.
    alias gsb='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
    alias ge='git-edit-new'

    # Push current branch to origin and set upstream if not set
    gpo() {
        local branch=$(git rev-parse --abbrev-ref HEAD)
        if [[ "$branch" == "HEAD" ]]; then
            echo "Error: Cannot push in detached HEAD state"
            return 1
        fi
        git push --set-upstream origin "$branch"
    }
else
    log_info " !  Git not found, skipping Git aliases"
    return
fi



