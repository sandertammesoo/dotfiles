#  A user-specific Zsh profile for interactive zsh(1) login shells, often used for 
#  exporting environment variables and running startup commands.
#
#  Setup user specific overriders for /etc/zprofile here. 
#  See zshbuiltins(1) and zshoptions(1) for more details.
log_trace "$(basename "${(%):-%x}")"

# Use nvim as default editor if available
if command -v nvim &> /dev/null; then
    export_n_log EDITOR=nvim
    # Use nvim as manpager `:h Man`
    export_n_log MANPAGER='nvim +Man!'
else
    export_n_log EDITOR=vim
    # Don't clear the screen after quitting a manual page
    export_n_log MANPAGER="less -X"
fi
