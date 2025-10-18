#!/usr/bin/env zsh

# Reload the shell (i.e. invoke as a login shell)
alias reload!=". $XDG_CONFIG_HOME/.zsh/.zshrc"
alias reload="reload!"
alias s=reload

if command -v yabai &> /dev/null; then
    log_success "yabai is installed, setting up aliases"
    alias restart-yabai="yabai --restart-service"
    alias restart-yabai-hard="yabai --restart-service"
else
    log_warn " yabai not found, skipping yabai aliases"
fi

if command -v skhd &> /dev/null; then
    log_success "skhd is installed, setting up aliases"
    alias restart-skhd="skhd --restart-service"
    alias restart-skhd-hard="skhd --restart-service"
else
    log_warn " skhd not found, skipping skhd aliases"
fi

if command -v sketchybar &> /dev/null; then
    log_success "sketchybar is installed, setting up aliases"
    alias restart-sketchybar="sketchybar --reload"
    alias restart-sketchybar-hard="brew services restart sketchybar"
else
    log_warn " sketchybar not found, skipping sketchybar aliases"
fi

# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color --group-directories-first"
  alias l="gls -lAh --color --group-directories-first"
  alias ll="gls -l --color --group-directories-first"
  alias la='gls -A --color --group-directories-first'

  # List only directories
  alias lsd="gls -lF --color | grep --color=never '^d'"
elif $(eza &>/dev/null)
then
  alias ls="eza --color=always --icons=always --group-directories-first --git"
  alias la="eza --color=always --icons=always --group-directories-first --git --all"
  alias ll="eza --color=always --icons=always --group-directories-first --git --long --no-time --no-user --header"
  alias l="eza --color=always --icons=always --group-directories-first --git  --long --no-time --no-user --header --all"

  # List only directories
  alias lsd="eza --color=always --icons=always --group-directories-first --git --long --no-time --no-user --header --all --dirs-only"
else
  alias l="ls -lAh"
  alias ll="ls -l"
  alias la="ls -A"
  # List only directories
  alias lsd="ls -lF | grep '^d'"
fi

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shortcuts
alias dr="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias cdf="cd $XDG_CONFIG_HOME/.dotfiles"
alias cdi="zi"
alias p="cd $PROJECTS_CD"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Get OS X Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='brew update; brew upgrade; brew cleanup; brew doctor;'

alias cls='clear' # Good 'ol Clear Screen command
alias cat='bat'
alias grep='grep --color=auto'
export_n_log GREP_COLOR='1;32'

# For https://github.com/cljoly/telescope-repo.nvim
# https://egeek.me/2020/04/18/enabling-locate-on-osx/

if command -v glocate &> /dev/null; then
    log_success "glocate is installed, setting up aliases"
    alias locate="glocate -d $HOME/locatedb"

    # Using cache_list requires `LOCATE_PATH` environment var to exist in session.
    # trouble shoot: `echo $LOCATE_PATH` needs to return db path.
    [[ -f "$HOME/locatedb" ]] && export LOCATE_PATH="$HOME/locatedb"
else
    log_warn " glocate not found, skipping glocate aliases"
fi

if command -v gupdatedb &> /dev/null; then
    log_success "gupdatedb is installed, setting up aliases"
    alias loaddb="gupdatedb --localpaths=$HOME --prunepaths=/Volumes --output=$HOME/locatedb"
else
    log_warn " gupdatedb not found, skipping gupdatedb aliases"
fi
