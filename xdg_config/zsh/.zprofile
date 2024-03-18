# ~/.config/.zsh/.zprofile
log_info "Loading $ZDOTDIR/.zprofile"

# export EDITOR=nvim
export EDITOR='code'
# export EDITOR=vim
debug "Set EDITOR=$EDITOR"

# Use nvim as manpager `:h Man`
#export MANPAGER='nvim +Man!'
# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";
debug "Set MANPAGER=$MANPAGER"

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}";

# Always enable colored `grep` output
export GREP_OPTIONS="--color=auto";

