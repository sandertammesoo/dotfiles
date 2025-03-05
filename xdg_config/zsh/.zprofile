#  A user-specific Zsh profile for interactive zsh(1) login shells, often used for exporting environment variables and running startup commands.
#
#  Setup user specific overriders for /etc/zprofile here. See zshbuiltins(1) and zshoptions(1) for
#  more details.
src "$(basename "${(%):-%x}")"

# Use nvim as default editor
export_n_log EDITOR=nvim

# Use nvim as manpager `:h Man`
export_n_log MANPAGER='nvim +Man!'
# Don’t clear the screen after quitting a manual page
# export_n_log MANPAGER="less -X"

# Highlight section titles in manual pages
export_n_log LESS_TERMCAP_md="${yellow}"

# Always enable colored `grep` output
export_n_log GREP_OPTIONS="--color=auto"
