#!/usr/bin/env zsh
# Miscellaneous helper functions for dotfiles setup and management
# Requires: helpers_logging.zsh for logging functions
# Usage: source this file in your zsh scripts
# Example: source "$HOME/.config/.dotfiles/helpers_misc.zsh"

################################################################################
# setup_gitconfig: Interactively set up a local gitconfig file if it doesn't exist.
# Prompts the user for their GitHub author name and email, and configures
# the appropriate credential helper based on the operating system.
# Examples:
#   setup_gitconfig
################################################################################
setup_gitconfig() {
  if ! [ -f git/gitconfig.local.symlink ]; then
    if [ "$(uname -s)" = "Darwin" ]; then
      git_credential='osxkeychain'
      log_debug "git_credential='osxkeychain'"
    else
      git_credential='cache'
      log_debug "git_credential='cache'"
    fi

    log_user ' - What is your github author name?'
    read -e git_authorname
    log_user ' - What is your github author email?'
    read -e git_authoremail

    log_info "  Creating git/gitconfig.local.symlink."
    # TODO: setup_gitconfig:18: no such file or directory: ./git/gitconfig.local.symlink
    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ./git/gitconfig.local.symlink.example > ./git/gitconfig.local.symlink
  else
    log_info "  git/gitconfig.local.symlink exists."
  fi
}

################################################################################
# get_zsh_files: Retrieve and categorize .zsh configuration files from the ZSH directory
# Usage: get_zsh_files [CATEGORY]
# CATEGORY can be one of: env, alias, func, completion, other
# If CATEGORY is omitted, all categories are returned
# Examples:
#   get_zsh_files env
#   get_zsh_files alias
#   get_zsh_files func
#   get_zsh_files completion
#   get_zsh_files other
#   get_zsh_files  # Returns all categories
################################################################################
function get_zsh_files() {
    local category="$1"
    log_verbose " > get_zsh_files called with category: '$1'"

    typeset -ga matched_files=()  # Make it global so it's accessible outside function
    
    # Get all zsh files
    SEARCH_DIR="${ZSH:-$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts}"
    local -a config_files=($SEARCH_DIR/**/*.zsh)
    
    # Categorize files without output
    for file in $config_files; do
        case "$file" in
            */homebrew/env.zsh|*/zoxide/env.zsh|*/zsh/config.zsh|*/zsh/fpath.zsh) continue ;;
            */env.zsh) [[ "$category" == "env" || -z "$category" ]] && matched_files+=($file) ;;
            */aliases.zsh) [[ "$category" == "alias" || -z "$category" ]] && matched_files+=($file) ;;
            */functions.zsh) [[ "$category" == "func" || -z "$category" ]] && matched_files+=($file) ;;
            */completion.zsh) [[ "$category" == "completion" || -z "$category" ]] && matched_files+=($file) ;;
            *) [[ "$category" == "other" || -z "$category" ]] && matched_files+=($file) ;;
        esac
    done

    if [[ ${#matched_files[@]} -eq 0 ]]; then
        log_verbose " > No files matched for category '$category'"
        return 1
    else
        log_verbose " > Found ${#matched_files} .zsh files for category '$category'"
        return 0
    fi
}