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
            */homebrew/env.zsh|*/zoxide/env.zsh|*/zsh/config.zsh|*/zsh/fpath.zsh|*/atuin/env.zsh|*/starship/env.zsh|*/navi/env.zsh) continue ;;
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

#################################################################################
# run_logged: Run a command, log it at VERBOSE level before execution, capture output
# and return the exit code. Usage:
#   output=$(run_logged cmd) && ...
# Or:
#   run_logged cmd; exit_code=$?
# Or (with arguments):
#   output=$(run_logged brew install FelixKratz/formulae/sketchybar)
#   exit_code=$?
#################################################################################
run_logged() {
    if [ $# -eq 0 ]; then
        _log VERBOSE "Running command: (none)"
        return 0
    fi

    local -a cmd_array
    cmd_array=("$@")
    _log VERBOSE "Running command: ${cmd_array[@]}"
    "$@" 2>&1
}

#################################################################################
# require_brew: Check if Homebrew is installed; log fatal and return 1 if not found.
# Usage: require_brew
# Example:
#   if require_brew; then
#     log_success "Homebrew is installed"
#   fi
#################################################################################
# Checks that Homebrew is installed; returns 1 with fatal log if not
require_brew() {
    _log VERBOSE "Checking if Homebrew is installed..."
    if ! command -v brew &>/dev/null; then
        _log FATAL "Homebrew not installed. Please install it first."
        return 1
    fi
    _log VERBOSE "Homebrew found at: $(command -v brew)"
}

###############################################################################
# brew_install_if_missing: Installs a brew formula if the named command is not found.
# Usage: brew_install_if_missing TOOL FORMULA
# TOOL: command name to check (e.g. "sketchybar")
# FORMULA: brew formula to install (e.g. "FelixKratz/formulae/sketchybar")
###############################################################################
brew_install_if_missing() {
    local tool="$1"
    local formula="$2"
    local cmd
    local output
    local exit_code

    _log VERBOSE "Checking if $tool is installed..."
    cmd="command -v $tool"
    _log VERBOSE "Running command: $cmd"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        _log VERBOSE "$tool found at: $output"
        _log SUCCESS "$tool is already installed."
        return 0
    fi

    cmd="brew info $tool"
    _log VERBOSE "Running command: $cmd"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    if echo "$output" | grep -q "Installed"; then
        _log VERBOSE "$tool is already installed according to brew info."
        _log SUCCESS "$tool is already installed."
        return 0
    fi

    _log USER "$tool not found. Installing $formula..."
    cmd="brew install $formula"
    _log VERBOSE "Running command: $cmd"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "$output" | output_stream FATAL
        _log FATAL "$tool installation failed!"
        return 1
    fi

    echo "$output" | output_stream
    _log SUCCESS "$tool installed successfully!"

    # Verify — fall back to brew info for packages without a CLI command
    if command -v "$tool" &>/dev/null; then
        _log SUCCESS "$tool installation verified."
    elif brew info "$tool" 2>/dev/null | grep -q "Installed"; then
        _log SUCCESS "$tool installation verified (via brew info)."
    else
        _log FATAL "$tool installation verification failed!"
        return 1
    fi
}

###############################################################################
# brew_trust_tap: Trust a non-official Homebrew tap so its formulae/casks load.
# Homebrew 6.0+ refuses to load third-party taps until trusted
# (HOMEBREW_REQUIRE_TAP_TRUST became the default). This is a no-op on older
# Homebrew without `brew trust`, idempotent (skips already-trusted taps), and
# tolerant (warns and returns 0 on failure so callers are not aborted).
# Usage: brew_trust_tap TAP            (e.g. "felixkratz/formulae")
###############################################################################
brew_trust_tap() {
    local tap="$1"
    local output
    local exit_code

    if [[ -z "$tap" ]]; then
        _log VERBOSE "brew_trust_tap: no tap given; skipping."
        return 0
    fi

    # Official Homebrew taps (homebrew/core, homebrew/cask, ...) are always trusted.
    if [[ "$tap" == homebrew/* ]]; then
        _log VERBOSE "Official tap needs no trust: $tap"
        return 0
    fi

    # `brew trust` only exists on Homebrew 6.0+; nothing to do on older versions.
    if ! brew trust --help &>/dev/null; then
        _log VERBOSE "brew trust unavailable (Homebrew < 6.0?); skipping trust for $tap"
        return 0
    fi

    # Already trusted? trust.json lists trusted taps under "taps".
    if brew trust --json v1 2>/dev/null | grep -qF "\"$tap\""; then
        _log VERBOSE "Tap already trusted: $tap"
        return 0
    fi

    _log USER "Trusting non-official tap: $tap"
    output=$(brew trust --tap "$tap" 2>&1)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream VERBOSE
        _log SUCCESS "Trusted tap: $tap"
    else
        echo "$output" | output_stream WARN
        _log WARN "Failed to trust tap: $tap (continuing)."
    fi
    return 0
}

###############################################################################
# brew_trust_brewfile_taps: Trust every non-official tap declared in a Brewfile.
# Reads `tap "owner/name"` directives and trusts each via brew_trust_tap, so
# `brew bundle` and the service bootstraps can load their formulae/casks under
# Homebrew 6.0+'s mandatory tap-trust. No-op on older Homebrew.
# Usage: brew_trust_brewfile_taps [BREWFILE]   (default: ./brewfiles/Brewfile)
###############################################################################
brew_trust_brewfile_taps() {
    local brewfile="${1:-./brewfiles/Brewfile}"
    local tap

    if [[ ! -f "$brewfile" ]]; then
        _log WARN "Brewfile not found at $brewfile; skipping tap trust."
        return 0
    fi

    # `brew trust` only exists on Homebrew 6.0+; nothing to do on older versions.
    if ! brew trust --help &>/dev/null; then
        _log VERBOSE "brew trust unavailable (Homebrew < 6.0?); skipping Brewfile tap trust."
        return 0
    fi

    _log VERBOSE "Trusting non-official taps declared in $brewfile..."
    # Collect taps from two sources (deduped), skipping commented-out lines:
    #   1. Explicit `tap "owner/repo"` directives.
    #   2. Tapped formulae/casks referenced by full path, e.g. `cask "owner/repo/name"`,
    #      which `brew bundle` auto-taps even without a matching `tap` line.
    while IFS= read -r tap; do
        [[ -z "$tap" ]] && continue
        brew_trust_tap "$tap"
    done < <(
        {
            grep -E '^[[:space:]]*tap[[:space:]]+"[^"]+"' "$brewfile" 2>/dev/null \
                | sed -E 's/^[[:space:]]*tap[[:space:]]+"([^"]+)".*/\1/'
            grep -E '^[[:space:]]*(brew|cask)[[:space:]]+"[^"/]+/[^"/]+/[^"]+"' "$brewfile" 2>/dev/null \
                | sed -E 's#^[[:space:]]*(brew|cask)[[:space:]]+"([^"/]+/[^"/]+)/[^"]+".*#\2#'
        } | sort -u
    )
}