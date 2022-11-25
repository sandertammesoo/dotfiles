# ~/.config/.zsh/.zshenv
#
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
export ZDOTDIR=$XDG_CONFIG_HOME/.zsh

# export fpath=(~/.config/zsh/completions/ $fpath)

# if [[ $s(command -v rg) ]]; then
#     export FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g ""'
# fi

# Determine if we are an SSH connection
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    export IS_SSH=true
else
    case $(ps -o comm= -p $PPID) in
        sshd|*/sshd) IS_SSH=true
    esac
fi

