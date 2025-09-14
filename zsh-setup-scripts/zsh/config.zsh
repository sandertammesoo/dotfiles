#!/bin/zsh
src "$(basename "${(%):-%x}")"

# Enable colorized output for 'ls' and other commands that support it
export CLICOLOR=true

# Define colors for file types when using 'ls'
# Format: a 22-character string, where each pair represents:
# 1st char = text color, 2nd char = background color
# Color codes:
#   a = Black       b = Red          c = Green       d = Brown/Yellow
#   e = Blue        f = Magenta      g = Cyan        h = Light Gray
#   A = Bold Black  B = Bold Red     C = Bold Green  D = Bold Yellow
#   E = Bold Blue   F = Bold Magenta G = Bold Cyan   H = Bold White
#   x = Default terminal background

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
export LSCOLORS="exfxcxdxbxegedabagacad"

# This depends on gdircolors being installed with coreutils (brew install coreutils)
# TODO  Make calling gdircolors safe, in case coreutils is not yet installed
export LS_COLORS=$(gdircolors -b)

fpath=($ZSH/functions $fpath)

autoload -U $ZSH/functions/*(:t)

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt SHARE_HISTORY # share history between sessions ???
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF

setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char
