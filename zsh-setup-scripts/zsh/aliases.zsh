#!/bin/zsh

# Reload the shell (i.e. invoke as a login shell)
alias reload!=". $XDG_CONFIG_HOME/.zsh/.zshrc"
alias reload="reload!"
alias s=reload

# {{{1 Edit Aliases
alias ez="$EDITOR $ZDOTDIR/.zshrc"
alias gn="cd $XDG_CONFIG_HOME/nvim/"
# alias en='$EDITOR ~/Git/config_manager/vim/.nvimrc'
# }}}

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
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; brew doctor;'

alias cls='clear' # Good 'ol Clear Screen command
alias grep='grep --color'

# For https://github.com/cljoly/telescope-repo.nvim
# https://egeek.me/2020/04/18/enabling-locate-on-osx/
if which glocate > /dev/null; then
  alias locate="glocate -d $HOME/locatedb"

  # Using cache_list requires `LOCATE_PATH` environment var to exist in session.
  # trouble shoot: `echo $LOCATE_PATH` needs to return db path.
  [[ -f "$HOME/locatedb" ]] && export LOCATE_PATH="$HOME/locatedb"
fi


alias loaddb="gupdatedb --localpaths=$HOME --prunepaths=/Volumes --output=$HOME/locatedb"

# useful only for Mac OS Silicon M1, 
# still working but useless for the other platforms
docker() {
  if [[ `uname -m` == "arm64" ]] && [[ "$1" == "run" || "$1" == "build" ]]; then
     /usr/local/bin/docker "$1" --platform linux/amd64 "${@:2}"
  else
     /usr/local/bin/docker "$@"
  fi
}
