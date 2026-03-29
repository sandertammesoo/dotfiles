#!/usr/bin/env zsh
##############################################################################
# Plugin Configuration
#
# This file is reserved for future zsh plugin configuration.
# Plugins like zsh-autosuggestions and zsh-syntax-highlighting are currently
# managed via Homebrew but not loaded here.
#
# To enable zsh-autosuggestions and zsh-syntax-highlighting:
#
# 1. Install via Homebrew:
#    brew install zsh-autosuggestions zsh-syntax-highlighting
#
# 2. Add to your shell configuration:
#    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#
# 3. If you get "highlighters directory not found" error, add to .zshenv:
#    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
#
# Note: Paths may differ on Intel Macs (/usr/local instead of /opt/homebrew)
##############################################################################

# Plugins are not currently loaded here
# Uncomment and modify the lines below when ready to enable:

# Custom strategy: glob the filesystem for the last word being typed.
# Avoids zsh-autosuggestions' built-in 'completion' strategy which uses zpty
# and is unreliable inside tmux.
_zsh_autosuggest_strategy_files() {
    local prefix="${1}"
    local last="${prefix##* }"
    [[ -z "$last" ]] && return

    setopt localoptions nullglob nocase_glob
    local -a matches=($last*(N))
    [[ ${#matches[@]} -eq 0 ]] && return

    local match="${matches[1]}"
    [[ -d "$match" && "$match" != */ ]] && match="${match}/"

    # Preserve the user's exact typed prefix to pass autosuggestions' case-sensitive
    # prefix check, then append only the remaining characters from the match.
    # e.g. typed "cd MI", match "misc/" → suggestion "cd MIsc/"
    typeset -g suggestion="${prefix}${match:${#last}}"
}

# Tokyo Night comment colour — visible in both WezTerm and tmux-256color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
# history: match from HISTFILE. files: fall back to filesystem glob.
ZSH_AUTOSUGGEST_STRATEGY=(files history)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
