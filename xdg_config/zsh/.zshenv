# A user-specific configuration file that is sourced for every Zsh shell,
# regardless of whether it is interactive or a login shell.
# .zshenv is always sourced.
# It is loaded after /etc/zshenv and before /etc/zprofile.
#
# Used for environment variables and minimal setup. Overrides /etc/zshenv.
# Most general ${ENV_VAR} variables should be saved here.

# Helper functions for printing loging info in to the terminal
typeset -gx DEBUG_DOTFILES_SETUP_LEVEL="WARN"
typeset -gx DEBUG_DOTFILES_SETUP="true"
source "$HOME/.config/.dotfiles/helpers.zsh"
src "$(basename "${(%):-%x}")"

export_n_log XDG_CONFIG_HOME="$HOME/.config"
export_n_log ZDOTDIR="$XDG_CONFIG_HOME/.zsh"
export_n_log ZSH="$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts"

# Add directories to PATH and MANPATH in batch (more efficient)
paths_to_add=(
  "$ZSH/bin"
  "/usr/local/sbin"
  "/usr/local/bin"
  "./bin"
  "$HOME/.local/bin"
)
for p in $paths_to_add; do
  add_to PATH "$p"
done

manpaths_to_add=(
  "/usr/local/git/man"
  "/usr/local/mysql/man"
  "/usr/local/man"
)
for mp in $manpaths_to_add; do
  add_to MANPATH "$mp"
done

# Uncomment to add custom completion paths
# export fpath=(~/.config/zsh/completions/ $fpath)

# Uncomment if you want `rg` (ripgrep) to be used with fzf
# if command -v rg &>/dev/null; then
#     export_n_log FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g ""'
# fi

# Detect if running in an SSH session
export_n_log IS_SSH="false"
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] || [[ "$(ps -o comm= -p $PPID)" == *sshd* ]]; then
  export_n_log IS_SSH="true"
fi
