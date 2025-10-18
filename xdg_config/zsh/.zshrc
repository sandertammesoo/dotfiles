# Zsh Run Commands - A user-specific configuration file sourced by interactive shells, 
# commonly used for shell customization like aliases and prompt settings.

# ~/.config/.zsh/.zshrc

# Track reload start time for summary
local ZSHRC_START_TIME=$SECONDS

# Homebrew must be sourced first
try_source "$ZSH/homebrew/env.zsh" error

# Load essential configs early
# Source configuration files
if ! try_source "$ZSH/zsh/config.zsh" error; then
    log_failure "Failed to load shell configuration"
    return 1
else
    log_success "Shell configuration loaded"
fi

# Stash your environment variables in $XDG_CONFIG_HOME/.localrc (~/.config/.localrc).
# This means they'll stay out of your main dotfiles repository (which may be public,
# like this one), but you'll have access to them in your scripts.
try_source "$XDG_CONFIG_HOME/.localrc" info

# Load environment variables from user-specific config
get_zsh_files env && {
    log_debug " > Sourcing ${#matched_files} environment setup files"
    for file in $matched_files; do try_source "$file" warn; done
} || log_debug " > No environment setup files found to source"

get_zsh_files other && {
    log_debug " > Sourcing ${#matched_files} other setup files"
    for file in $matched_files; do try_source "$file" warn; done
} || log_debug " > No other setup files found to source"

get_zsh_files alias && {
    log_debug " > Sourcing ${#matched_files} alias setup files"
    for file in $matched_files; do try_source "$file" warn; done
} || log_debug " > No alias setup files found to source"

get_zsh_files func && {
    log_debug " > Sourcing ${#matched_files} function setup files"
    for file in $matched_files; do try_source "$file" warn; done
} || log_debug " > No function setup files found to source"

# Initialize autocomplete before loading completions
log_debug " > Initializing autocomplete"
autoload -U compinit
compinit

# Use a custom location for the completion dump file to avoid permission issues
if [[ -f "$XDG_CONFIG_HOME/.zcompdump" ]]; then
    log_debug " > Using existing completion dump file at $XDG_CONFIG_HOME/.zcompdump"
else
    log_debug " > No existing completion dump file found, creating new one at $XDG_CONFIG_HOME/.zcompdump"
    touch "$XDG_CONFIG_HOME/.zcompdump"
fi
compinit -d "$XDG_CONFIG_HOME/.zcompdump" -C -u # -C -u to avoid security checks


get_zsh_files completion && {
    log_debug " > Sourcing ${#matched_files} completion setup files"
    for file in $matched_files; do try_source "$file" warn; done
} || log_debug " > No completion setup files found to source"


# Source zoxide environment variable setup
try_source "$ZSH/zoxide/env.zsh" error
# For zoxide completions to work, the above file must be sourced after
# compinit is called. You may have to rebuild your completions cache by
# running rm ~/.zcompdump*; compinit.
rm -f "$XDG_CONFIG_HOME/.zcompdump"*; compinit -d "$XDG_CONFIG_HOME/.zcompdump" -C -u # Rebuild completions cache

# Cleanup
unset config_files env_files func_files alias_files completion_files other_files

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Display reload summary (only if log_debugis enabled)
if is_debug_enabled; then
  local ZSHRC_DURATION=$((SECONDS - ZSHRC_START_TIME))
  log_success "Shell configuration loaded in ${ZSHRC_DURATION}s"
fi
