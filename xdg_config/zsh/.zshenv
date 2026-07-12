# A user-specific configuration file that is sourced for every Zsh shell,
# regardless of whether it is interactive or a login shell.
# .zshenv is always sourced.
# It is loaded after /etc/zshenv and before /etc/zprofile.
#
# Used for environment variables and minimal setup. Overrides /etc/zshenv.
# Most general ${ENV_VAR} variables should be saved here.

# Helper functions for printing loging info in to the terminal

# Skip loading helpers_logging in test environments
# Check for ShellSpec environment by looking for SHELLSPEC_* variables or spec file patterns
if [[ -z "$SHELLSPEC_SPECDIR" && -z "$SHELLSPEC_ROOT" && ! "$0" =~ "shellspec" ]]; then

  # Minimum severity level for logging (messages below this are ignored)
  typeset -gx LOG_LEVEL="${LOG_LEVEL:-WARN}"  # Options: TRACE, VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL

  # Color output control
  typeset -gx LOG_COLOR="${LOG_COLOR:-always}"        # Options: auto, always, never

  # Debug mode toggle - controls whether logging is active
  # false = Only ERROR and FATAL messages are logged (production default)
  # true  = All messages at or above LOG_LEVEL are logged (debug mode)
  typeset -gx LOG_ENABLED="${LOG_ENABLED:-true}"

  # Load logging helper functions
  autoload -Uz throw catch

  source "$HOME/projects/dotfiles/helpers.zsh"

  # Detect if running in an SSH session
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] || [[ "$(ps -o comm= -p $PPID)" == *sshd* ]]; then
    export_n_log IS_SSH="true"
  else
    export_n_log IS_SSH="false"
  fi

  # XDG Base Directory Specification
  # https://specifications.freedesktop.org/basedir-spec/latest/
  export_n_log CONFIG_DIR=".config"
  export_n_log DATA_DIR=".local/share"  
  export_n_log CACHE_DIR=".cache"       
  export_n_log STATE_DIR=".local/state"
  export_n_log RUNTIME_DIR="/tmp"       
  export_n_log BIN_DIR=".local/bin"   

  export_n_log XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/$CONFIG_DIR}"
  export_n_log XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/$DATA_DIR}"
  export_n_log XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/$CACHE_DIR}"
  export_n_log XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/$STATE_DIR}"
  export_n_log XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$RUNTIME_DIR}"
  export_n_log XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/$BIN_DIR}"


  # Set Zsh-specific environment variables
  export_n_log ZDOTDIR="$XDG_CONFIG_HOME/.zsh"
  export_n_log ZSH="$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts"

  # XDG-compliant application configurations
  export_n_log LESSHISTFILE="$XDG_STATE_HOME/less/history"
  export_n_log HISTFILE="$XDG_STATE_HOME/zsh/history"
  export_n_log CARGO_HOME="$XDG_DATA_HOME/cargo"
  export_n_log RUSTUP_HOME="$XDG_DATA_HOME/rustup"
  export_n_log NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
  export_n_log NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
  export_n_log DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
  export_n_log COMPOSER_HOME="$XDG_DATA_HOME/composer"
  export_n_log COMPOSER_CACHE_DIR="$XDG_CACHE_HOME/composer"
  export_n_log SHELL_SESSION_DIR="${XDG_STATE_HOME}/zsh/sessions"
  export_n_log SHELL_SESSION_FILE="$SHELL_SESSION_DIR/$TERM_SESSION_ID.session"

  # Add directories to PATH (ensure no duplicates)
  paths=(
    "$ZSH/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "./bin"
    "$HOME/.local/bin"
    "$CARGO_HOME/bin"
  )
  for p in $paths; do
    add_to PATH "$p"
  done

  # Add directories to MANPATH (ensure no duplicates)
  manpaths=(
    "/usr/local/git/man"
    "/usr/local/mysql/man"
    "/usr/local/man"
  )
  for mp in $manpaths; do
    add_to MANPATH "$mp"
  done

  # Load fpath settings early for functions and completions
  if ! try_source "$ZSH/zsh/fpath.zsh" error; then
      log_fatal "Failed to load fpath settings"
      return 1
  fi

fi
