#!/usr/bin/env zsh

# Set default values only if not already defined
typeset -gx DEBUG_DOTFILES_SETUP_LEVEL="${DEBUG_DOTFILES_SETUP_LEVEL:-WARN}"
typeset -gx DEBUG_DOTFILES_SETUP="${DEBUG_DOTFILES_SETUP:-false}"

# Define log levels
typeset -A LOG_LEVELS=(
  DEBUG "DEBUG" SRC " SRC " INFO "INFO " WARN "WARN " ERROR "ERROR"
  SUCCESS "  OK " FAIL " NOK " USER "USER " USER2 " ... "
)
typeset -A LOG_COLORS=(
  DEBUG magenta SRC blue INFO cyan WARN yellow ERROR red
  SUCCESS green FAIL red USER white TRACE gray
)

# Color function: Applies styles dynamically
function color() {
  local color=$1 style=$2 b=0
  shift

  case $style in
    norm | n)
      b=0
      shift
      ;;
    bold | b)
      b=1
      shift
      ;;
    italic | i)
      b=2
      shift
      ;;
    underline | u)
      b=4
      shift
      ;;
    inverse | in)
      b=7
      shift
      ;;
    strikethrough | s)
      b=9
      shift
      ;;
  esac

  case $color in
    black | b) echo "\033[${b};30m${@}\033[0;m" ;;
    red | r) echo "\033[${b};31m${@}\033[0;m" ;;
    green | g) echo "\033[${b};32m${@}\033[0;m" ;;
    yellow | y) echo "\033[${b};33m${@}\033[0;m" ;;
    blue | bl) echo "\033[${b};34m${@}\033[0;m" ;;
    magenta | m) echo "\033[${b};35m${@}\033[0;m" ;;
    cyan | c) echo "\033[${b};36m${@}\033[0;m" ;;
    white | w) echo "\033[${b};37m${@}\033[0;m" ;;
    gray | gr) echo "\033[38;5;238m${@}\033[0m" ;;
    *) echo "\033[${b};38;5;$((${color}))m${@}\033[0;m" ;;
  esac
}

##############################################################################
# to_relative: Convert an absolute or relative path (TARGET) into a relative
#             path from the current working directory (PWD). Works even if
#             TARGET doesn’t yet exist (no cd necessary).
#
# Examples:
#   If PWD=/Users/sander/projects/test_backup_helper_functions
#   to_relative /Users/sander => ../..
#   to_relative .backups/test.txt.bak0 => ./.backups/test.txt.bak0
#   to_relative ../../some/other/dir => ../../some/other/dir
##############################################################################
function to_relative() {
  local target="$1"

  # 1) If target is not absolute (no leading /), make it absolute via $PWD
  #    e.g. "foo/bar" => "/current/dir/foo/bar"
  [[ "$target" != /* ]] && target="$PWD/$target"

  # 2) Base is just $PWD as an absolute
  local base="$PWD"

  # 3) Split both paths on '/' into arrays
  #    Turn leading '/' into empty first elements, so we handle root properly
  local -a TPARTS
  local -a BPARTS

  # Remove any trailing '/' so we don't get empty last elements
  target="${target%%/}"
  base="${base%%/}"

  TPARTS=( "${(@s:/:)target}" )
  BPARTS=( "${(@s:/:)base}" )

  # 4) Find common prefix
  local i=1
  local tcount=$#TPARTS
  local bcount=$#BPARTS
  local min_len=$(( tcount < bcount ? tcount : bcount ))

  while (( i <= min_len )) && [[ "${TPARTS[i]}" == "${BPARTS[i]}" ]]; do
    (( i++ ))
  done

  # 5) Add ../ for each remaining segment in base
  #    (i.e. go “up” until we reach the common ancestor)
  local result=""
  local j=$i
  while (( j <= bcount )); do
    [[ -n "${BPARTS[j]}" ]] && result+="../"
    (( j++ ))
  done

  # 6) Append leftover TPARTS
  while (( i <= tcount )); do
    result+="${TPARTS[i]}"
    (( i++ ))
    (( i <= tcount )) && result+="/"
  done

  # 7) If empty => same directory => "."
  echo "${result:-.}"
}

# log_msg debug white norm "message"
function log_msg() {
  local level=${LOG_LEVELS[${1:u}]-$LOG_LEVELS[LOG]}  # Convert to uppercase, default to LOG
  local level_color=${LOG_COLORS[${1:u}]-$LOG_COLORS[LOG]}
  local msg_color=$2 msg_style=$3 msg="$4"

  local script_name="${(%):-%x}"
  [[ "$script_name" != /* ]] || script_name="$(to_relative "$script_name")"
  local caller_info="${script_name}:${(%):-%L}"  # Current script and line number
  
  [[ -n ${funcfiletrace[2]} ]] && caller_info="$(to_relative "${funcfiletrace[2]}")"

  # Filter messages based on debug level
  local allowed_levels=("DEBUG" "SRC" "INFO" "WARN" "ERROR" "OK" "NOK" "USER")
  local index=${allowed_levels[(ie)$DEBUG_DOTFILES_SETUP_LEVEL]:-7}  # Default to ERROR
  local level_index=${allowed_levels[(ie)$1]:-7}

  (( level_index >= index )) && \
    echo -e "$(color $level_color "[ $level ]") $(color $msg_color $msg_style $msg) $(color ${LOG_COLORS[TRACE]} "(at $caller_info)")"
}

# Source files conditionally
try_source() {
  local file=$1 log_level=${2:u}  # Convert to lowercase
  [[ -z $log_level ]] && log_level=INFO
  local color=${LOG_COLORS[${log_level}]-$LOG_COLORS[INFO]}

  if [[ -a $file ]]; then
    source "$file"
  else
    log_msg $log_level $color norm "File not found: $file"
  fi
}

# Export and log environment variables
export_n_log() {
  local varname="${1%%=*}" value="${1#*=}"
  typeset -gx "$varname=$value"
  [[ "$DEBUG_DOTFILES_SETUP" == "true" ]] && log_msg DEBUG $LOG_COLORS[DEBUG] norm "$varname=$value"
}

add_to() {
  local varname=$1
  shift  # Remove the first argument (variable name), leaving only the paths

  # Ensure at least one path is provided
  [[ -z $varname || $# -eq 0 ]] && return 1

  # Get the current value of the variable
  eval "local current_value=\${$varname}"

  local new_paths=()  # Array to store paths that need to be added

  # Iterate over all provided paths
  for new_path in "$@"; do
    if [[ ":$current_value:" != *":$new_path:"* ]]; then
      new_paths+=("$new_path")  # Add only if not already in the variable
    # else
    #   log_msg DEBUG $LOG_COLORS[DEBUG] norm "$varname already contains $new_path"
    fi
  done

  # If there are new paths to add, update the variable
  if [[ ${#new_paths[@]} -gt 0 ]]; then
    local updated_value="${(j.:.)new_paths}${current_value:+:$current_value}"
    # eval "export $varname=\"$updated_value\""
    eval "export_n_log $varname=\"$updated_value\""
  fi
}

# Define logging functions dynamically
# Disable logging functions if DEBUG_DOTFILES_SETUP is false
if [[ "$DEBUG_DOTFILES_SETUP" == "true" ]]; then
  for level in "${(@k)LOG_LEVELS}"; do
    eval "${level:l}() { log_msg $level \$LOG_COLORS[$level] norm \"\$1\"; }"
  done
else
  for level in "${(@k)LOG_LEVELS}"; do 
    eval "${level:l}() { true; }"; 
  done
fi

info_stream2() {
  while read data; do
    printf "[ $(color blue $LOG_LEVELS[USER2]) ] $data\n"
  done
}
info_stream() {
  local prefix="[ $(color blue $LOG_LEVELS[USER2]) ]"
  local width=${#prefix}  # Get the length of the prefix
  # local indent="$(printf "%*s" $width '')"  # Create an indent of the same width
  local indent="         "  # Smaller indent for wrapped lines

  while IFS= read -r line; do
    echo "$line" | fold -s -w $((COLUMNS - width - 2)) | sed "1s/^/$prefix /; 2,\$s/^/$indent /"
  done
}

setup_gitconfig() {
  if ! [ -f git/gitconfig.local.symlink ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
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

    info "  Creating git/gitconfig.local.symlink."
    # TODO: setup_gitconfig:18: no such file or directory: ./git/gitconfig.local.symlink
    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ./git/gitconfig.local.symlink.example > ./git/gitconfig.local.symlink
  else
    info "  git/gitconfig.local.symlink exists."
  fi
}
