#!/usr/bin/env zsh


# Define color codes
COLOR_DEBUG="\033[0;32m" # Green
COLOR_OK="\033[0;32m" # Green
COLOR_INFO="\033[0;34m"  # Blue
COLOR_WARN="\033[0;33m"  # Yellow
COLOR_ERROR="\033[0;31m" # Red
COLOR_NOK="\033[0;31m" # Red
COLOR_RESET="\033[0m"

# Define levels
L_DEBUG="DEBUG"
L_LOG=" LOG "
L_INFO="INFO "
L_WARN="WARN "
L_ERROR="ERROR"
L_OK="  OK "
L_NOK=" NOK "
L_USER="USER "
L_USER2=" ... "

export DEBUG_DOTFILES_SETUP=true
export DEBUG_DOTFILES_SETUP_LEVEL="INFO"

log_message () {
    local level="$1"
    local message="$2"
    local color="$3"

    case $DEBUG_DOTFILES_SETUP_LEVEL in
      DEBUG)
        levels=($L_USER $L_DEBUG $L_LOG $L_INFO $L_WARN $L_ERROR $L_OK $L_NOK)
        ;;
      LOG)
        levels=($L_USER $L_LOG $L_INFO $L_WARN $L_ERROR $L_OK $L_NOK)
        ;;
      INFO)
        levels=($L_USER $L_INFO $L_WARN $L_ERROR $L_OK $L_NOK)
        ;;
      WARN)
        levels=($L_USER $L_WARN $L_ERROR $L_NOK)
        ;;
      ERROR)
        levels=($L_USER $L_ERROR $L_NOK)
        ;;
      *)
        levels=()
        ;;
    esac

    if [[ " ${levels[@]} " =~ " ${level} " ]]; then
      printf "\r  [ $color$level$COLOR_RESET ] $message\n"
    fi
  }

if [[ "$DEBUG_DOTFILES_SETUP" == "true" ]]; then

  debug () {
    log_message $L_DEBUG "$1" "$COLOR_DEBUG"
  }

  log_info () {
    log_message $L_LOG "$1" "$COLOR_DEBUG"
  }

  info () {
    log_message $L_INFO "$1" "$COLOR_INFO"
  }

  warn () {
    log_message $L_WARN "$1" "$COLOR_WARN"
  }

  error () {
    log_message $L_ERROR "$1" "$COLOR_ERROR"
  }

  user () {
    log_message $L_USER "$1" "$COLOR_WARN"
  }

  success () {
    log_message $L_OK "$1" "$COLOR_OK"
  }

  info_stream () {
    while read data; do
        printf "\r  [ \033[00;34m$L_USER2\033[0m ] $data\n"
    done
    # echo ''
  }

  fail () {
    log_message $L_NOK "$1" "$COLOR_NOK"
  }

else

  debug () {
    true
  }

  log_info () {
    true
  }

  info () {
    true
  }

  warn () {
    true
  }

  error () {
    log_message $L_ERROR "$1" "$COLOR_ERROR"
  }

  user () {
    log_message $L_USER "$1" "$COLOR_WARN"
  }

  success () {
    log_message $L_OK "$1" "$COLOR_OK"
  }

  info_stream () {
    while read data; do
        printf "\r  [ \033[00;34m$L_USER2\033[0m ] $data\n"
    done
    # echo ''
  }

  fail () {
    log_message $L_NOK "$1" "$COLOR_NOK"
  }

fi

setup_gitconfig () {
  if ! [ -f git/gitconfig.local.symlink ]
  then
    if [ "$(uname -s)" = "Darwin" ]
    then
      git_credential='osxkeychain'
      debug "git_credential='osxkeychain'"
    else
      git_credential='cache'
      debug "git_credential='cache'"
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    log_info "  Creating git/gitconfig.local.symlink."
    # TODO: setup_gitconfig:18: no such file or directory: ./git/gitconfig.local.symlink
    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ./git/gitconfig.local.symlink.example > ./git/gitconfig.local.symlink
  else
    log_info "  git/gitconfig.local.symlink exists."
  fi
}
