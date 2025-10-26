#!/usr/bin/env zsh
################################################################################
# helpers_logging.zsh - Comprehensive logging framework for Zsh
#
# This module provides a flexible, multi-level logging system with:
# - 7 log levels: TRACE, VERB, DEBUG, INFO, WARN, ERROR, FATAL
# - Configurable formatting (standard, minimal, detailed)
# - Color support with automatic terminal detection
# - Caller information tracking for debugging
# - Stream processing utilities
# - Environment variable management helpers
#
# Configuration Variables:
#   LOG_LEVEL    - Minimum level to log (default: INFO)
#   LOG_ENABLED  - Enable/disable debug mode (default: false)
#                  When false, only ERROR and FATAL are logged
#                  When true, messages at or above LOG_LEVEL are logged
#   LOG_FORMAT   - Message format (default: detailed)
#                  Options: standard, minimal, detailed, output_stream
#   LOG_COLOR    - Color output (default: auto)
#                  Options: auto, always, never
#
# Quick Start:
#   source /path/to/helpers_logging.zsh
#   enable_debug              # Turn on debug logging
#   set_log_level DEBUG       # Set minimum level
#   log_info "Hello, world!"  # Log an info message
#
# For detailed documentation, see function headers below.
################################################################################

# Guard against double-loading
# Check both the variable AND that key public functions are actually defined
# (Warp terminal can cache env vars but not functions between sessions)
if [[ -n "$HELPERS_LOGGING_LOADED" ]] && (( ${+functions[log_info]} )); then
  return 0
fi
typeset -gx HELPERS_LOGGING_LOADED=1

################################################################################
# Configuration Variables
# Set default values only if not already defined - can be overridden in environment
################################################################################

# Minimum severity level for logging (messages below this are ignored)
typeset -gx LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Message formatting style
typeset -gx LOG_FORMAT="${LOG_FORMAT:-detailed}"  # Options: standard, minimal, detailed

# Color output control
typeset -gx LOG_COLOR="${LOG_COLOR:-auto}"        # Options: auto, always, never

# Debug mode toggle - controls whether logging is active
# false = Only ERROR and FATAL messages are logged (production default)
# true  = All messages at or above LOG_LEVEL are logged (debug mode)
typeset -gx LOG_ENABLED="${LOG_ENABLED:-false}"

################################################################################
# Log Level Definitions
# Standard log levels in ascending order of severity (0 = most verbose)
################################################################################
typeset -Ag LOG_LEVELS=(
  [TRACE]=0    # Most verbose - trace execution flow
  [VERB]=1     # Verbose debugging information
  [DEBUG]=2    # General debugging information
  [OUTPUT]=2    # Output stream messages
  [INFO]=3     # Informational messages (default minimum)
  [WARN]=4     # Warning messages
  [ERROR]=5    # Error messages
  [FATAL]=6    # Fatal errors
)

# ANSI color codes for each log level
typeset -Ag LOG_COLORS=(
  [TRACE]="242"
  [VERB]="magenta"
  [DEBUG]="blue"
  [OUTPUT]="blue"
  [INFO]="cyan"
  [WARN]="yellow"
  [ERROR]="red"
  [FATAL]="red"  # Will be styled bold
)

# Display names with consistent 5-character width for alignment
typeset -Ag LOG_NAMES=(
  [TRACE]="TRACE"
  [VERB]="VERB "
  [DEBUG]="DEBUG"
  [OUTPUT]=" ... "
  [INFO]="INFO "
  [WARN]="WARN "
  [ERROR]="ERROR"
  [FATAL]="FATAL"
)

# Message adornments for semantic logging functions
SUCCESS_ADORN="  ✓  "    # Success marker
WARNING_ADORN="  !  "    # Warning marker
FAILURE_ADORN="  ✗  "    # Failure marker
USER_ADORN="  ▶  "       # User interaction marker
USER2_ADORN="  ...  "    # Secondary user interaction marker

################################################################################
# set_log_level - Set the minimum logging level
#
# Sets the minimum severity level for log messages. Messages below this level
# will not be logged (unless LOG_ENABLED is false, in which case only ERROR
# and FATAL are logged regardless).
#
# Usage: set_log_level <LEVEL>
#   LEVEL: TRACE, VERB, DEBUG, INFO, WARN, ERROR, or FATAL
#
# Examples:
#   set_log_level DEBUG
#   set_log_level INFO
#
# Returns: 0 on success, 1 if invalid level provided
################################################################################
function set_log_level() {
  local level="${1:u}"
  
  # Validate the level first
  if [[ -z "${LOG_LEVELS[$level]}" ]]; then
    log_error "Invalid log level: $level. Valid levels: ${(k)LOG_LEVELS}"
    return 1
  fi
  
  # Log the change BEFORE setting the new level (if debugging is enabled)
  # Behavior depends on current log level:
  # - If current level <= DEBUG: log all changes (current level allows DEBUG messages)
  # - If current level > DEBUG: only log when setting to TRACE/VERB/DEBUG
  if is_debug_enabled; then
    local new_level_num="${LOG_LEVELS[$level]}"
    local current_level_num="${LOG_LEVELS[$LOG_LEVEL]}"
    local DEBUG_LEVEL_NUM="${LOG_LEVELS[DEBUG]}"
    
    if (( current_level_num <= DEBUG_LEVEL_NUM )); then
      # Current level is DEBUG or lower - log all changes
      _log DEBUG "Log level set to $level"
    elif (( new_level_num <= DEBUG_LEVEL_NUM )); then
      # Current level > DEBUG, but setting to DEBUG or lower - use 'always'
      _log DEBUG "Log level set to $level" ALWAYS
    fi
  fi
  
  # Now set the level
  _set_log_level "$level"
  return 0
}

################################################################################
# _set_log_level - Internal: Set log level without logging
#
# Sets LOG_LEVEL variable silently. Used during initialization to avoid
# circular logging. Public code should use set_log_level() instead.
################################################################################
function _set_log_level() {
  local level="${1:u}"
  if [[ -n "${LOG_LEVELS[$level]}" ]]; then
    typeset -gx LOG_LEVEL="$level"
    return 0
  else
    return 1
  fi
} 

################################################################################
# print_log_level - Output the current log level
#
# Prints the current LOG_LEVEL value to stdout. Useful for debugging or
# displaying configuration.
#
# Example: log_debug "Current level: $(print_log_level)"
################################################################################
function print_log_level() {
  echo "$LOG_LEVEL"
}

################################################################################
# is_debug_enabled - Check if debug mode is active
#
# Returns: 0 (true) if LOG_ENABLED="true", 1 (false) otherwise
#
# Example:
#   if is_debug_enabled; then
#       perform_expensive_debug_operation
#   fi
################################################################################
function is_debug_enabled() {
  [[ "$LOG_ENABLED" == "true" ]]
}

################################################################################
# Debug Mode Control Functions
#
# enable_debug  - Turn on debug mode (logs confirmation message)
# disable_debug - Turn off debug mode (logs confirmation message)
# toggle_debug  - Switch debug mode on/off (logs confirmation message)
#
# Internal variants (_enable_debug, _disable_debug, _toggle_debug) perform
# the same actions silently without logging.
################################################################################

function enable_debug() {
  _enable_debug
  _log DEBUG "Debugging enabled"
}

function _enable_debug() {
  typeset -gx LOG_ENABLED="true"
}

function disable_debug() {
  _log DEBUG "Debugging disabled"
  _disable_debug
}

function _disable_debug() {
  typeset -gx LOG_ENABLED="false"
}

function toggle_debug() {
  is_debug_enabled && disable_debug || enable_debug
}

function _toggle_debug() {
  is_debug_enabled && _disable_debug || _enable_debug
}

################################################################################
# should_log - Determine if a message at given level should be logged
#
# Checks both LOG_ENABLED and LOG_LEVEL to determine if logging should occur.
# ERROR and FATAL always return true regardless of settings.
#
# Usage: should_log <LEVEL>
# Returns: 0 if message should be logged, 1 otherwise
#
# Example: should_log DEBUG || return 0
################################################################################
function should_log() {
  local level="${1:u}"
  local current_level_num="${LOG_LEVELS[$LOG_LEVEL]:-2}"
  local msg_level_num="${LOG_LEVELS[$level]:-0}"

  # Always log ERROR and FATAL regardless of LOG_ENABLED state
  [[ "$level" == "ERROR" || "$level" == "FATAL" ]] && return 0
  
  # Check if debug is enabled and message level meets threshold
  if is_debug_enabled && (( msg_level_num >= current_level_num )); then
    return 0
  else
    return 1
  fi
}

################################################################################
# Color and Formatting Helper Functions
################################################################################

################################################################################
# _parse_color_args - Internal: Parse mixed color/style/text arguments
#
# Separates color, styles, and text from a mixed argument list.
# Outputs three lines: color, styles (space-separated), text
#
# Internal helper for color_text()
################################################################################
function _parse_color_args() {
  local -a args=("$@")
  local color="" styles=() text="" found_text=0
  
  # Handle edge cases
  [[ ${#args[@]} -eq 0 ]] && { echo ""; echo ""; echo ""; return; }
  [[ ${#args[@]} -eq 1 ]] && { echo ""; echo ""; echo "${args[1]}"; return; }
  
  # Parse arguments to separate color/styles from text
  for arg in "${args[@]}"; do
    case "$arg" in
      # Colors
      black|red|green|yellow|blue|magenta|cyan|white|gray)
        if [[ $found_text -eq 0 && -z "$color" ]]; then
          color="$arg"
        else
          found_text=1
          text+="${text:+ }$arg"
        fi
        ;;
      # Styles
      bold|italic|underline|inverse|strikethrough|norm)
        if [[ $found_text -eq 0 ]]; then
          styles+=("$arg")
        else
          text+="${text:+ }$arg"
        fi
        ;;
      # Numeric color codes (0-255)
      [0-9]|[0-9][0-9]|[01][0-9][0-9]|2[0-4][0-9]|25[0-5])
        if [[ $found_text -eq 0 && -z "$color" ]]; then
          color="$arg"
        else
          found_text=1
          text+="${text:+ }$arg"
        fi
        ;;
      # Everything else is text
      *)
        found_text=1
        text+="${text:+ }$arg"
        ;;
    esac
  done
  
  # Output: color, styles (space-separated), text
  echo "$color"
  echo "${styles[*]}"
  echo "$text"
}

################################################################################
# _build_escape_sequence - Internal: Build ANSI color escape sequence
#
# Converts color names and style names to ANSI escape codes.
# Outputs the escape sequence without the reset code.
#
# Internal helper for color_text()
################################################################################
function _build_escape_sequence() {
  local color="$1"
  local styles="$2"
  local color_code="" style_codes=()
  
  # Convert style names to codes
  for style in ${=styles}; do
    case "$style" in
      norm) style_codes+=(0) ;;
      bold) style_codes+=(1) ;;
      italic) style_codes+=(3) ;;
      underline) style_codes+=(4) ;;
      inverse) style_codes+=(7) ;;
      strikethrough) style_codes+=(9) ;;
    esac
  done
  
  # Convert color name to code
  case "$color" in
    black) color_code="30" ;;
    red) color_code="31" ;;
    green) color_code="32" ;;
    yellow) color_code="33" ;;
    blue) color_code="34" ;;
    magenta) color_code="35" ;;
    cyan) color_code="36" ;;
    white) color_code="37" ;;
    gray) color_code="38;5;238" ;;
    "") color_code="" ;;  # No color
    *) color_code="38;5;${color}" ;;  # Assume numeric color code
  esac
  
  # Build the escape sequence
  if [[ ${#style_codes[@]} -eq 0 && -z "$color_code" ]]; then
    echo ""
    return
  fi
  
  local escape_seq="\e["
  local sep=""
  for code in "${style_codes[@]}"; do
    escape_seq+="${sep}${code}"
    sep=";"
  done
  if [[ -n "$color_code" ]]; then
    escape_seq+="${sep}${color_code}"
  fi
  escape_seq+="m"
  
  echo "$escape_seq"
}

################################################################################
# color_text - Apply color and styling to text
#
# Wraps text in ANSI color codes based on LOG_COLOR setting and terminal detection.
#
# Usage: color_text [COLOR] [STYLE...] TEXT
#   COLOR: Color name (red, blue, etc.) or ANSI code (0-255)
#   STYLE: bold, italic, underline, inverse, strikethrough, norm
#   TEXT:  The message to colorize (all remaining arguments)
#
# Examples:
#   color_text red bold "Error occurred"
#   color_text 32 "Success"
#   color_text blue italic underline "Important note"
#
# Respects LOG_COLOR: never=no color, always=force color, auto=detect terminal
################################################################################
function color_text() {
  # Parse arguments into components
  local -a parsed
  parsed=("${(@f)$(_parse_color_args "$@")}")
  local color="${parsed[1]}"
  local styles="${parsed[2]}"
  local text="${parsed[3]}"
  
  # Skip coloring if disabled or not a terminal
  # Note: Checks stderr (-t 2) for terminal detection since ERROR/FATAL go to stderr
  # This provides consistent behavior even though INFO messages go to stdout
  if [[ "$LOG_COLOR" == "never" ]] || [[ "$LOG_COLOR" == "auto" && ! -t 2 ]]; then
    # Use echo -e to preserve any existing ANSI codes in the text
    echo -e "$text"
    return
  fi
  
  # Build escape sequence and output
  local escape_seq="$(_build_escape_sequence "$color" "$styles")"
  
  if [[ -n "$escape_seq" ]]; then
    echo -e "${escape_seq}${text}\e[0m"
  else
    echo -e "$text"
  fi
}

################################################################################
# format_log_message - Format a log entry with severity, timestamp, and caller
#
# Produces formatted log output according to LOG_FORMAT setting:
#   - standard: [LEVEL] message
#   - minimal:  LEVEL: message
#   - detailed: [LEVEL] timestamp (file:line:function) message
#
# Usage: format_log_message SEVERITY MESSAGE [CALLER_INFO]
#
# Returns formatted string suitable for logging. Preserves any existing ANSI
# color codes in the message text (e.g., from piped command output with colors).
################################################################################
function format_log_message() {
  local level="$1" message="$2" caller="${3:-}"
  local level_color="${LOG_COLORS[$level]}"
  local level_name="${LOG_NAMES[$level]}"
  local timestamp=""
  
  # If caller info is not provided but format needs it, get it automatically
  # Use depth=2 because stack is: actual_caller -> format_log_message -> get_caller_info
  if [[ -z "$caller" && "$LOG_FORMAT" == "detailed" ]]; then
    caller="$(get_caller_info 2)"
  fi
  
  # Note: The message may already contain ANSI color codes (e.g., from piped 
  # command output). These are preserved by not applying any transformations
  # to the message itself - only the log prefix and metadata are colored.
  # Use echo -e to interpret escape sequences in the message.
  
  case "$LOG_FORMAT" in
    minimal)
      echo -e "$(color_text "$level_color" "[$level_name]") $message"
      ;;
    detailed)
      timestamp="$(date '+%H:%M:%S')"
      if [[ -n "$caller" ]]; then
        echo -e "$(color_text gray "$timestamp") $(color_text "$level_color" "[$level_name]") $message $(color_text gray "($caller)")"
      else
        echo -e "$(color_text gray "$timestamp") $(color_text "$level_color" "[$level_name]") $message"
      fi
      ;;
    output_stream)
      timestamp="$(date '+%H:%M:%S')"
      echo -e "$(color_text gray "$timestamp") $(color_text "$level_color" "[$level_name]") $message"
      ;;
    *)  # standard
      if [[ -n "$caller" ]]; then
        echo -e "$(color_text "$level_color" "[$level_name]") $message $(color_text gray "($caller)")"
      else
        echo -e "$(color_text "$level_color" "[$level_name]") $message"
      fi
      ;;
  esac
}

################################################################################
# to_relative - Convert absolute path to workspace-relative path
#
# Usage: to_relative /full/path/to/file.sh
#
# If path is under WORKSPACE_ROOT, returns relative path (e.g., "scripts/file.sh")
# Otherwise returns the full path unchanged
################################################################################
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

################################################################################
# get_caller_info - Extract caller information from the call stack
#
# Examines the call stack to find the function, file, and line number of the
# code that invoked a logging function. Skips internal logging functions to
# identify the actual caller.
#
# Sets global variables:
#   CALLER_FILE     - Relative path to calling file
#   CALLER_LINE     - Line number in calling file
#   CALLER_FUNCTION - Name of calling function
################################################################################

function get_caller_info() {
  # Accept optional depth parameter, or auto-detect based on call stack
  local depth="${1:-}"
  
  # If depth not specified, detect it based on the calling function
  # NOTE: This auto-detection is fragile - if function names change or call chain
  # is modified, the depth values may become incorrect. Consider passing explicit
  # depth when possible, or refactoring to pass skip-frames through call chain.
  if [[ -z "$depth" ]]; then
    # Check who called us by looking at funcstack
    local caller_func="${funcstack[2]:-}"
    case "$caller_func" in
      _log) depth=3 ;;
      format_log_message) depth=2 ;;
      *) depth=1 ;;  # Direct call or unknown caller
    esac
  fi
  
  # Use funcfiletrace to get caller info, but make it more robust
  local caller_trace="${funcfiletrace[$depth]:-}"
  if [[ -n "$caller_trace" ]]; then
    # Extract filename and line number
    local file="${caller_trace%:*}" # Extract filename
    local line="${caller_trace##*:}"  # Extract line number
    
    # Convert to relative path from current directory
    local relative_path="$(to_relative "$file")"
    
    # Truncate path to show only last 3 directory levels + filename for readability
    # e.g., ../../../../tmp/xyz/long/path/to/file/script.sh becomes ../to/file/script.sh
    local truncated_path="$relative_path"
    local dir_count=$(echo "$relative_path" | tr -cd '/' | wc -c | tr -d ' ')
    if (( dir_count > 3 )); then
      # Get the last 3 directory levels + filename, with edge case handling
      truncated_path=$(echo "$relative_path" | awk -F'/' '{
        if (NF >= 3) print "../" $(NF-2) "/" $(NF-1) "/" $NF
        else print $0
      }')
    fi
    
    echo "${truncated_path}:$line"
  fi
}


################################################################################
# _log - Core logging implementation
#
# Internal function that all public logging functions delegate to. Handles
# severity checking, message formatting, colorization, and output routing.
#
# Usage: _log LEVEL MESSAGE [ALWAYS_LOG]
#   LEVEL:      TRACE, DEBUG, INFO, WARN, ERROR, or FATAL
#   MESSAGE:    The text to log
#   ALWAYS_LOG: Optional "ALWAYS" flag to bypass severity threshold
#
# Outputs to stderr only if LEVEL >= LOG_LEVEL (unless ALWAYS_LOG is set)
################################################################################
function _log() {
  local level="$1" message="$2" always_log="${3:-}"
  level="${level:u}"  # Convert to uppercase
  always_log="${always_log:u}"  # Convert to uppercase for comparison

  # Check if we should log this level (skip check if ALWAYS flag is set)
  [[ "$always_log" == "ALWAYS" ]] || should_log "$level" || return 0
  
  local caller_info=""
  [[ "$LOG_FORMAT" == "detailed" ]] && caller_info="$(get_caller_info)"
  local formatted_message="$(format_log_message "$level" "$message" "$caller_info")"
  
  # Send ERROR and FATAL to stderr, others to stdout
  if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
    echo "$formatted_message" >&2
  else
    echo "$formatted_message"
  fi
}

################################################################################
# Public Logging Functions - Primary API
#
# These are the main logging functions for different severity levels.
# All delegate to _log() for consistent formatting and behavior.
#
# log_trace   - Most verbose, for detailed execution tracing
# log_verbose - Extended info, more detail than info
# log_debug   - Developer diagnostics
# log_info    - General informational messages
# log_warn    - Warnings (automatically adorned with ⚠ symbol)
# log_error   - Errors and failures
# log_fatal   - Critical failures
#
# All respect LOG_LEVEL threshold and LOG_ENABLED state
################################################################################

function log_trace() { _log TRACE "$1"; }
function log_verbose() { _log VERB "$1"; }
function log_debug() { _log DEBUG "$1"; }
function log_info() { _log INFO "$1"; }
function log_warn() { _log WARN "$(color_text yellow bold "$WARNING_ADORN") $1"; }
function log_error() { _log ERROR "$1"; }
function log_fatal() { _log FATAL "$1"; }

################################################################################
# Semantic Status Logging
#
# These functions use semantic naming (success/failure) rather than severity
# levels, automatically selecting appropriate levels and adorning with symbols.
################################################################################

function log_success() { _log INFO "$(color_text green bold "$SUCCESS_ADORN") $1"; }
function log_failure() { _log ERROR "$(color_text red bold "$FAILURE_ADORN") $1"; }
function log_user() { _log INFO "$(color_text white bold "$USER_ADORN") $1"; }
function log_user2() { _log INFO "$(color_text white bold "$USER2_ADORN") $1"; }

################################################################################
# l_always - Force logging regardless of LOG_ENABLED state
#
# Wrapper that bypasses the LOG_ENABLED check, useful for critical messages
# that must always be displayed even when logging is disabled.
#
# Usage: l_always LOG_FUNCTION MESSAGE
#   l_always log_trace "Critical trace"
#   l_always log_info "Always show this"
#   l_always log_error "Must see this error"
#
# Works with any logging function: log_trace, log_debug, log_info, log_warn,
# log_error, log_fatal, log_success, log_failure, and their short aliases
################################################################################
function l_always() {
  local func="$1"
  shift
  
  # For basic log levels, use _log with ALWAYS flag
  case "$func" in
    log_trace|trace) _log TRACE "$*" ALWAYS ;;
    log_verb|verb) _log VERB "$*" ALWAYS ;;
    log_debug|debug) _log DEBUG "$*" ALWAYS ;;
    log_info|info) _log INFO "$*" ALWAYS ;;
    log_warn|warn) _log WARN "$*" ALWAYS ;;
    log_error|error) _log ERROR "$*" ALWAYS ;;
    log_fatal|fatal) _log FATAL "$*" ALWAYS ;;
    log_success|success)
      # Use the actual log_success function with adorning, bypassing LOG_ENABLED check
      _log INFO "$(color_text green bold "$SUCCESS_ADORN") $*" ALWAYS
      ;;
    log_failure|failure|fail)
      # Use the actual log_failure function with adorning, bypassing LOG_ENABLED check
      _log ERROR "$(color_text red bold "$FAILURE_ADORN") $*" ALWAYS
      ;;
    *)
      _log ERROR "Unknown logging function: $func"
      return 1
      ;;
  esac
}

################################################################################
# Stream Processors - Pipe command output through logging
#
# These functions allow piping command output through the logging system,
# applying appropriate log levels and formatting to each line.
#
# Usage:
#   command 2>&1 | log_stream LEVEL  # Generic, any level
#   command 2>&1 | info_stream        # INFO level
#   command 2>&1 | error_stream       # ERROR level
#
# Examples:
#   curl -v https://api.example.com 2>&1 | log_stream DEBUG
#   make build 2>&1 | info_stream
#   some_risky_cmd 2>&1 | error_stream
################################################################################

function log_stream() {
  local level="${1:-INFO}"
  while IFS= read -r line; do
    _log "${level:u}" "$line"
  done
}

function error_stream() { log_stream ERROR; }
function info_stream() { log_stream INFO; }

function output_stream() {
  local level="${1:-OUTPUT}"

  # Temporarily force a non-detailed format so _log doesn't append caller info
  local _old_log_format="$LOG_FORMAT"
  typeset LOG_FORMAT="output_stream"

  # Temporarily force colors to always be enabled to preserve ANSI codes from piped input
  local _old_log_color="$LOG_COLOR"
  typeset LOG_COLOR="always"

  # Track the active ANSI color prefix to apply to continuation lines
  local active_prefix=""
  local reset=$'\x1b[0m'

  while IFS= read -r line; do
    # Extract all ANSI escape sequences from the line to determine the active color.
    # We look for ESC[ followed by numbers/semicolons and ending with 'm'.
    local line_prefix=""
    local has_reset=false
    local line_has_escapes=false
    local has_non_reset_escape=false
    
    # Scan for all CSI sequences in the line
    local temp="$line"
    while [[ "$temp" == *$'\x1b['* ]]; do
      line_has_escapes=true
      # Get substring after first ESC[
      local after="${temp#*$'\x1b['}"
      # Extract codes up to first 'm'
      local codes="${after%%m*}"
      
      # Check if this is a reset (code 0 or empty)
      if [[ "$codes" == "0" ]] || [[ -z "$codes" ]]; then
        has_reset=true
      else
        # Build the escape sequence
        line_prefix=$'\x1b['${codes}m
        has_non_reset_escape=true
      fi
      
      # Move past this sequence to find the next one
      temp="${after#*m}"
    done
    
    # If we found a new color prefix (and it's not just a reset), update active_prefix
    if [[ -n "$line_prefix" ]] && [[ "$has_non_reset_escape" == true ]]; then
      active_prefix="$line_prefix"
    fi
    
    # If line has no color escapes (only reset or none) but we have an active prefix, colorize it
    # This ensures continuation lines and lines with just resets get the same color
    if [[ -n "$active_prefix" ]] && [[ "$has_non_reset_escape" == false ]]; then
      # If the line has only a reset, apply color to the text before the reset
      if [[ "$line_has_escapes" == true ]] && [[ "$has_reset" == true ]]; then
        # Extract text before the reset sequence
        local text_before_reset="${line%%$'\x1b['*}"
        # Rebuild: colored text + original reset
        line="${active_prefix}${text_before_reset}${reset}"
      else
        # No escapes at all, just add color
        line="${active_prefix}${line}${reset}"
      fi
    fi
    
    # Log each line individually (this gives each line its own timestamp and prefix)
    _log "${level:u}" "$line"
    
    # If we encountered a reset, clear the active prefix
    if [[ "$has_reset" == true ]]; then
      active_prefix=""
    fi
  done

  # Restore original settings
  typeset LOG_FORMAT="$_old_log_format"
  typeset LOG_COLOR="$_old_log_color"
}

################################################################################
# init_logging - Initialize logging system from environment
#
# Called automatically when this file is sourced. Validates LOG_LEVEL and
# LOG_COLOR environment variables, auto-detects terminal color capabilities,
# and sets up sensible defaults.
#
# Environment Variables:
#   LOG_LEVEL  - Validated and applied (defaults to INFO if invalid)
#   LOG_COLOR  - auto/always/never (auto-detects terminal support)
#   LOG_FORMAT - standard/minimal/detailed
################################################################################
function init_logging() {
  # Validate and set level from environment if provided
  if [[ -n "$LOG_LEVEL" ]]; then
    if ! _set_log_level "$LOG_LEVEL"; then
      _log WARN "Invalid LOG_LEVEL '$LOG_LEVEL' in environment, falling back to INFO" ALWAYS
      _set_log_level "INFO"
    fi
  fi
  
  # Auto-detect color support
  if [[ "$LOG_COLOR" == "auto" ]]; then
    if [[ -t 2 ]] && command -v tput &>/dev/null && tput colors &>/dev/null; then # terminal supports colors
      typeset -gx LOG_COLOR="always"
    else
      typeset -gx LOG_COLOR="never"
    fi
  fi
  typeset -gx HELPERS_LOGGING_INITIALIZED=1  
  
  # Load logging helper functions
  autoload -Uz throw catch
}

# Initialize on load
init_logging

################################################################################
# Utility Functions - File Sourcing
################################################################################

################################################################################
# try_source - Safely source a file if it exists
#
# Designed for optional file sourcing where missing files are not errors.
# Useful for loading optional configuration files or plugins.
#
# Usage: try_source FILE [LOG_LEVEL]
#   try_source "~/.zshrc.local" "WARN"
#   try_source "/etc/custom.conf"
#
# Returns:
#   0 - File doesn't exist (not an error) OR sources successfully
#   1 - File exists but fails to source (actual error)
################################################################################

try_source() {
  local file="$1" level="${2:-WARN}"
  
  if [[ -f "$file" ]]; then
    if source "$file" 2>/dev/null; then
      _log VERB "Sourced $file"
      return 0
    else
      _log "${level:u}" "Failed to source $file"
      return 1
    fi
  else
    _log "${level:u}" "File not found: $file"
    return 0  # Missing files not an error (optional sourcing pattern)
  fi

  # {
  #   # "try" block
  #   [[ -f "$file" ]] || throw MyExceptFileNotFound
  #   source "$file" || throw MyExceptFailedToSource
  #   _log VERB "Sourced $file"
  # } always {
  #   # "always" block
  #   # code

  #   # "catch" block
  #   if catch *; then
  #     case $CAUGHT in
  #       (MyExceptFileNotFound)
  #         _log "${level:u}" "Caught my own exception: $CAUGHT"
  #         ;;
  #       (MyExceptFailedToSource)
  #         _log "${level:u}" "Caught my own exception: $CAUGHT"
  #         ;;
  #       (*)
  #         _log "${level:u}" "Caught some other exception: $CAUGHT"
  #         ;;
  #     esac
  #   fi

  #   # "finally" block
  #   # code
  # }
}

################################################################################
# Utility Functions - Environment variable management
################################################################################

################################################################################
# export_n_log - Export a variable with trace logging
#
# Usage: export_n_log VAR=VALUE
#   export_n_log API_KEY="secret123"
#   export_n_log PATH="/usr/local/bin:$PATH"
#
# Security: Only logs the variable NAME, not the value, to protect sensitive
# data from appearing in logs.
################################################################################

export_n_log() {
  _export_n_log "$1"
  # Only log variable name (not value) to avoid exposing sensitive data
  local assignment="$1"
  local varname="${assignment%%=*}"
  local value="${assignment#*=}"
  _log TRACE "$(color_text ${LOG_COLORS[TRACE]} bold "Exported variable:") $varname = ${value}"
}

################################################################################
# _export_n_log - Internal export without logging
#
# Validates VAR=VALUE format and performs the export. Used by export_n_log and
# add_to functions. Returns error if format is invalid.
################################################################################

_export_n_log() {
  local assignment="$1"
  if [[ "$assignment" == *=* ]]; then
    local varname="${assignment%%=*}"
    local value="${assignment#*=}"
    export "$varname=$value"
  else
    _log ERROR "$(color_text ${LOG_COLORS[ERROR]} bold "Invalid assignment:") $assignment. Use VAR=VALUE format."
    return 1
  fi
}

################################################################################
# add_to - Add paths to environment variable (avoiding duplicates)
#
# Safely adds one or more paths to PATH, MANPATH, or similar colon-separated
# environment variables. Skips paths already present.
#
# Usage: add_to VAR PATH...
#   add_to PATH "/usr/local/bin" "/opt/bin"
#   add_to MANPATH "/usr/local/share/man"
#
# Returns 1 if called without variable name or paths
################################################################################
add_to() {
  local varname=$1
  shift  # Remove the first argument (variable name), leaving only the paths

  # Validate arguments
  if [[ -z $varname || $# -eq 0 ]]; then
    _log ERROR "add_to requires a variable name and at least one path"
    return 1
  fi

  # Get the current value of the variable
  eval "local current_value=\${$varname}"

  local new_paths=()  # Array to store paths that need to be added

  # Iterate over all provided paths
  for new_path in "$@"; do
    if [[ ":$current_value:" != *":$new_path:"* ]]; then
      new_paths+=("$new_path")  # Add only if not already in the variable
      if is_debug_enabled; then
        # _log TRACE "Adding $new_path to $varname"
        _log TRACE "$(color_text ${LOG_COLORS[TRACE]} bold "Adding to $varname:") $new_path"
      fi
    elif is_debug_enabled; then
      _log TRACE "Skipping add to $varname: already contains $new_path"
    fi
  done

  # If there are new paths to add, update the variable
  if [[ ${#new_paths[@]} -gt 0 ]]; then
    local updated_value="${(j.:.)new_paths}${current_value:+:$current_value}"
    eval "_export_n_log $varname=\"$updated_value\""
  fi
}