# Zsh Run Commands - A user-specific configuration file sourced by interactive shells, commonly used for shell customization like aliases and prompt settings.

# ~/.config/.zsh/.zshrc
src "$(basename "${(%):-%x}")"

# Stash your environment variables in $XDG_CONFIG_HOME/.localrc (~/.config/.localrc).
# This means they'll stay out of your main dotfiles repository (which may be public,
# like this one), but you'll have access to them in your scripts.
# Load environment variables from user-specific config
try_source "$XDG_CONFIG_HOME/.localrc"

# Homebrew must be sourced first
try_source "$ZSH/homebrew/env.zsh" error

# Load essential configs early
try_source "$ZSH/zsh/config.zsh" warn
try_source "$ZSH/zsh/fpath.zsh" warn

# Fetch all *.zsh files
typeset -U config_files
config_files=($ZSH/**/*.zsh)

# Categorize files in a single pass for efficiency
env_files=()
alias_files=()
func_files=()
completion_files=()
other_files=()

for file in $config_files; do
    case "$file" in
        */homebrew/env.zsh) continue ;; # Exclude from env_files
        */zoxide/env.zsh) continue ;; # Exclude from env_files
        */zsh/config.zsh) continue ;; # Exclude
        */zsh/fpath.zsh) continue ;; # Exclude
        */env.zsh) env_files+="$file" ;;
        */aliases.zsh) alias_files+="$file" ;;
        */functions.zsh) func_files+="$file" ;;
        */completion.zsh) completion_files+="$file" ;;
        *) other_files+="$file" ;; # Everything else
    esac
done

info "Sourcing ${#env_files} environment setup files"
for file in $env_files; do
    try_source "$file" warn
done

info "Sourcing ${#other_files} other files"
for file in $other_files; do
    try_source "$file" warn
done

info "Sourcing ${#alias_files} alias files"
for file in $alias_files; do
    try_source "$file" warn
done

info "Sourcing ${#func_files} function files"
for file in $func_files; do
    try_source "$file" warn
done

# Initialize autocomplete before loading completions
info "Initializing autocomplete"
autoload -U compinit
# compinit
compinit -d "$XDG_CONFIG_HOME/.zcompdump"

info "Sourcing ${#completion_files} completion files"
for file in $completion_files; do
    try_source "$file" warn
done

# Source zoxide environment variable setup
try_source "$ZSH/zoxide/env.zsh" error
# For zoxide completions to work, the above file must be sourced after
# compinit is called. You may have to rebuild your completions cache by
# running rm ~/.zcompdump*; compinit.

# Cleanup
unset config_files env_files func_files alias_files completion_files other_files
