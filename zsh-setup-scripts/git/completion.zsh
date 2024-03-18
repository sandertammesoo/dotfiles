#!/bin/zsh
# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).

# Check if 'git' is NOT available
if (( ! $+commands[git] )); then
    warn "'git' is not installed."
    return
fi

# Check if 'brew' is NOT available
if (( ! $+commands[brew] )); then
    warn "'brew' is not installed."
    return
fi

completion="$(brew --prefix)/share/zsh/site-functions/_git"

if test -f $completion
then
  #source $completion
else 
  warn "Could not find $completion"
fi
