#!/usr/bin/env zsh
# set_log_level "VERB"

# Load XDG Base Directory variables if not already set
typeset -gx XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
typeset -gx XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.data}"
typeset -gx XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
typeset -gx ZDOTDIR="$XDG_CONFIG_HOME/.zsh"
typeset -gx ZSH="$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts"

fpath=($ZSH/functions $fpath) # Add custom functions to fpath
autoload -U $ZSH/functions/*(:t) # load all functions

# Shell Options
# Must be set before compinit is called

# Base Options
setopt LOCAL_TRAPS       # Allow functions to have local traps
setopt NO_BG_NICE       # Don't nice background tasks
setopt NO_HUP           # Don't send HUP signal to running jobs when shell exits
setopt NO_LIST_BEEP     # Don't beep on completion
setopt NO_BEEP          # don't beep

# Directory Navigation
#setopt AUTO_CD          # If a command isn't valid but is a directory, cd to it
setopt AUTO_CD            # Alternative way to set AUTO_CD
setopt AUTO_PUSHD       # Make cd push the old directory onto the dirstack
setopt PUSHD_IGNORE_DUPS # Don't push duplicate directories
setopt PUSHD_MINUS      # Exchange meaning of + and - when used with a number to specify a directory in the stack
setopt PUSHD_SILENT     # Don't print dirstack after pushd/popd
setopt PUSHD_TO_HOME    # Have pushd with no arguments act like 'pushd $HOME'

setopt PROMPT_SUBST # allow variable and command substitution in prompts
setopt CORRECT # autocorrect commands
setopt COMPLETE_IN_WORD # complete in the middle of a word
setopt IGNORE_EOF # don't exit on Ctrl-D

# History Options
setopt EXTENDED_HISTORY     # Save timestamp in history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first
setopt HIST_IGNORE_DUPS     # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS    # Don't display a line previously found
setopt HIST_IGNORE_SPACE    # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks before recording entry
setopt HIST_VERIFY          # Don't execute the line directly; instead, perform history expansion and reload the line into the editing buffer
setopt INC_APPEND_HISTORY   # Write to history file immediately, not when shell exits
setopt APPEND_HISTORY       # Append to the history file, don't overwrite it
setopt SHARE_HISTORY        # Share history between all sessions

# Set XDG-compliant history file
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000       # Number of commands to remember in memory
export SAVEHIST=50000       # Number of commands to save in history file

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
# setopt complete_aliases # expand aliases in completion

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

# Set up the session directory/file.
export SHELL_SESSION_DIR="${XDG_STATE_HOME}/zsh/sessions" # TODO: use XDG_DATA_HOME
export SHELL_SESSION_FILE="$SHELL_SESSION_DIR/$TERM_SESSION_ID.session"
#mkdir -m 700 -p "$SHELL_SESSION_DIR"


# Shell colors and appearance

# Enable colorized output for 'ls' and other commands that support it
export_n_log CLICOLOR=true

# LS_COLORS is used by the GNU version of 'ls' (e.g., 'gls' or 'ls' from coreutils).
# This depends on gdircolors being installed with coreutils (brew install coreutils).
if command -v gdircolors &> /dev/null; then
    if [[ ! -f "$XDG_CONFIG_HOME/.dircolors" ]]; then
        gdircolors -p > "$XDG_CONFIG_HOME/.dircolors"
    fi
    eval "$(gdircolors -b "$XDG_CONFIG_HOME/.dircolors")"
else
    # Fallback colors for GNU ls if gdircolors is not available
    log_debug "gdircolors not found, using fallback LS_COLORS"
    export_n_log LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32'
fi

# Define colors for file types when using 'ls'
# Format: a 22-character string, where each pair represents:
# 1st char = text color, 2nd char = background color
# Color codes:
#   a = Black       b = Red          c = Green       d = Brown/Yellow
#   e = Blue        f = Magenta      g = Cyan        h = Light Gray
#   A = Bold Black  B = Bold Red     C = Bold Green  D = Bold Yellow
#   E = Bold Blue   F = Bold Magenta G = Bold Cyan   H = Bold White
#   x = Default terminal background
#
# Breakdown of the pairs in "exfxcxdxbxegedabagacad":
#   ex = Directory                 (Bright Blue text, Default background)
#   fx = Symbolic Link             (Cyan text, Default background)
#   cx = Socket                    (Green text, Default background)
#   dx = Pipe                      (Brown text, Default background)
#   bx = Executable File           (Bright Red text, Default background)
#   eg = Block Device              (Bright Blue text, Bright Green background)
#   ed = Character Device          (Bright Blue text, Brown background)
#   ab = Setuid Executable         (Black text, Bright Red background)
#   ag = Setgid Executable         (Black text, Bright Green background)
#   ac = Sticky Bit + Other Execute (Black text, Cyan background)
#   ad = Sticky Bit + No Execute   (Black text, Brown background)
# LSCOLORS is used by the BSD/macOS version of 'ls' (the default on macOS).
export_n_log LSCOLORS="exfxcxdxbxegedabagacad"
