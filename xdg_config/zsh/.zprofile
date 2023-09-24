# ~/.config/.zsh/.zprofile
#

# export EDITOR=nvim
export EDITOR='code'
# export EDITOR=vim

# Use nvim as manpager `:h Man`
# export MANPAGER='nvim +Man!'
# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}";

# Always enable colored `grep` output
export GREP_OPTIONS="--color=auto";

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

