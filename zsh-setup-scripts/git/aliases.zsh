
# Shortcuts
alias g="git"

# Basic functions
alias gpull='git pull'
alias gpush='git push'
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r' # Remove `+` and `-` from start of diff lines; just rely upon color.
alias gpr='git pull --rebase'
alias gpp='git pull --prune'

# Adding helpers
alias gadd='git add .'
alias gca='git add -A && git commit -m'

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

gpo() {
    git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)
}

