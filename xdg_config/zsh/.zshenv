# Helper functions for printing loging info in to the terminal
source $XDG_CONFIG_HOME/.dotfiles/helpers.zsh

# ~/.config/.zsh/.zshenv
log_info "Loading $ZDOTDIR/.zshenv"

# .zshenv is always sourced.
# Most ${ENV_VAR} variables should be saved here.
# It is loaded before .zshrc

# The order of zsh dotfiles to be loaded:
# /etc/zshenv
# ZDOTDIR/.zshenv
# /etc/zsrofile
# ZDOTDIR/.zprofile
# /etc/zshrc
# ZDOTDIR/.zshrc
# /etc/zshlogin
# ZDOTDIR/.zshlogin


export XDG_CONFIG_HOME=$HOME/.config
debug "Set XDG_CONFIG_HOME=$XDG_CONFIG_HOME"

export ZDOTDIR=$XDG_CONFIG_HOME/.zsh
debug "Set ZDOTDIR=$ZDOTDIR"

# export fpath=(~/.config/zsh/completions/ $fpath)

# if [[ $s(command -v rg) ]]; then
#     export FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g ""'
# fi

debug "Determine if we are an SSH connection"
export IS_SSH=false
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    export IS_SSH=true
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) IS_SSH=true
    esac
fi
debug "Set IS_SSH=$IS_SSH"
