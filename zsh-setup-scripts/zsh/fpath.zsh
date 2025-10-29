#!/usr/bin/env zsh

# Add custom completions directory
log_verbose "Add custom completions directory $XDG_CONFIG_HOME/zsh/completions to fpath"
export fpath=("$XDG_CONFIG_HOME/zsh/completions" $fpath)

# Add Homebrew completions early (before compinit)
# Note: We check for Homebrew in standard locations since it may not be in PATH yet
local brew_prefix=""
local homebrew_found=false

# Check for Homebrew in standard installation paths
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    brew_prefix="/opt/homebrew"
    homebrew_found=true
elif [[ -x "/usr/local/bin/brew" ]]; then
    brew_prefix="/usr/local"
    homebrew_found=true
elif command -v brew &> /dev/null; then
    # Fallback: try to get prefix from brew command if it's already in PATH
    brew_prefix="$(brew --prefix 2>/dev/null)"
    [[ -n "$brew_prefix" ]] && homebrew_found=true
fi

if [[ "$homebrew_found" == true ]]; then
    local completion_path="$brew_prefix/share/zsh/site-functions"
    if [[ -d "$completion_path" ]]; then
        export fpath=("$completion_path" $fpath)
        log_verbose "Added Homebrew completions to fpath early: $completion_path"
    else
        log_warn "Homebrew completion directory not found: $completion_path"
    fi
else
    log_warn "Homebrew not found, skipping Homebrew completions fpath setup"
fi

log_verbose "Add each topic folder to fpath so that they can add functions and completion scripts"
for topic_folder in "$ZSH"/*; do
  if [[ -d "$topic_folder" ]]; then
    log_trace "$(color_text ${LOG_COLORS[TRACE]} bold "Adding to fpath:") $topic_folder"
    export fpath=("$topic_folder" $fpath)
  fi
done
