# shellcheck shell=zsh
# ShellSpec Helper for Dotfiles Project

# This callback function will be invoked only once before loading specfiles.
spec_helper_precheck() {
  minimum_version "0.28.1"
}

# This callback function will be invoked after a specfile has been loaded.
spec_helper_loaded() {
  # Set up test environment variables
  export TEST_ENV_CLEAN=true
}

# This callback function will be invoked after core modules has been loaded.  
spec_helper_configure() {
  # Import custom matchers
  import 'support/custom_matchers'
  
  # Note: We don't load helpers_logging.zsh globally here because each test
  # needs to control when and how it's loaded (with different LOG_LEVEL values)
}

# =============================================================================
# TEST CONFIGURATION CONSTANTS
# =============================================================================

# Path depth for caller info truncation testing
# Must match the truncation depth in helpers_logging.zsh (last N directory levels)
readonly CALLER_INFO_PATH_DEPTH=3

# =============================================================================
# HELPER FUNCTIONS FOR TEST SETUP
# =============================================================================

# Helper functions for test setup
setup_test_environment() {
    # Force re-initialization by unsetting the guard
    unset HELPERS_LOGGING_LOADED
    unset HELPERS_LOGGING_INITIALIZED

    # Reset to known state - use explicit values for clean environment
    export TEST_ENV_CLEAN=true
    export LOG_LEVEL="INFO"
    export LOG_FORMAT="standard"
    export LOG_COLOR="auto"
    export LOG_ENABLED="false"
}

cleanup_test_environment() {
    # Clean up any test-specific variables
    unset TEST_VAR EXPORT_TEST
}

# Generic function to source framework with specific log level
# Usage: source_with_loglevel "TRACE"|"DEBUG"|"INFO"|etc.
source_with_loglevel() {
    local level="${1:-INFO}"
    export LOG_LEVEL="$level"
    source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
}

# Convenience wrappers for common log levels (backward compatibility)
source_with_loglevel_trace() {
    source_with_loglevel "TRACE"
}

source_with_loglevel_debug() {
    source_with_loglevel "DEBUG"
}

source_with_loglevel_info() {
    source_with_loglevel "INFO"
}

# Helper function to get the next higher log level (for testing level filtering)
# This encapsulates test-specific knowledge of the log level hierarchy
# Usage: get_higher_log_level "DEBUG"  # Returns: INFO
get_higher_log_level() {
    local current_level="$1"
    case "$current_level" in
        'TRACE') echo "DEBUG" ;;
        'DEBUG') echo "INFO" ;;
        'INFO')  echo "WARN" ;;
        'WARN')  echo "ERROR" ;;
        'ERROR') echo "FATAL" ;;
        'FATAL') echo "FATAL" ;;  # FATAL is highest, stays the same
        *) echo "INFO" ;;  # Default fallback
    esac
}

# Helper function to create a temporary script with nested directory path
# This is useful for testing caller information in deeply nested file structures
# The nested path depth is specifically chosen to test the path truncation logic
# that shows only the last CALLER_INFO_PATH_DEPTH directory levels.
# Usage: create_nested_temp_script <script_content>
# Returns: The output of running the script
create_nested_temp_script_for_logging() {
    local script_content="$1"
    local script_path path_dir helpers_path
    
    # Create base temp directory with error checking
    if ! path_dir="$(mktemp -d)"; then
        echo "ERROR: Failed to create temporary directory" >&2
        return 1
    fi
    
    # Validate temp directory was created successfully (defense in depth)
    if [ ! -d "$path_dir" ]; then
        echo "ERROR: Temporary directory validation failed" >&2
        return 1
    fi
    
    # Set up trap to ensure cleanup on exit (EXIT fires on both success and failure)
    # ERR provides additional safety. RETURN is bash-specific and not portable to zsh.
    trap "rm -rf '$path_dir'" EXIT ERR
    
    # Create nested subdirectories to test path truncation
    # Depth matches CALLER_INFO_PATH_DEPTH for consistency with implementation
    mkdir -p "$path_dir/long/path/to/file"
    
    # Create the temporary script file in the nested directory
    script_path="$path_dir/long/path/to/file/calling_script.$$.sh"
    
    # Get path to helpers_logging.zsh
    helpers_path="$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
    
    # Write the script header and content
    cat > "$script_path" <<SCRIPT_HEADER
#!/bin/zsh
# Reset logging guards to allow fresh initialization
unset HELPERS_LOGGING_LOADED HELPERS_LOGGING_INITIALIZED
# Source the logging framework
source "$helpers_path"
SCRIPT_HEADER
    
    # Append the custom script content
    echo "$script_content" >> "$script_path"
    
    # Make script executable
    chmod +x "$script_path"
    
    # Run the script and capture output
    local output
    output="$("$script_path" 2>&1)"
    
    # Trap will handle cleanup automatically on function exit
    # Return the captured output for assertions
    echo "$output"
}

# =============================================================================
# TEST CONFIGURATION HELPERS (DRY improvements)
# =============================================================================

# Set standard test configuration with all parameters
# Usage: configure_logging_test "minimal" "true" "never"
configure_logging_test() {
    local format="${1:-minimal}"
    local enabled="${2:-true}"
    local color="${3:-never}"
    export LOG_FORMAT="$format"
    export LOG_ENABLED="$enabled"
    export LOG_COLOR="$color"
}

# Preset configurations for common test scenarios
configure_minimal_logging() {
    configure_logging_test "minimal" "true" "never"
}

configure_detailed_logging() {
    configure_logging_test "detailed" "true" "never"
}

configure_standard_logging() {
    configure_logging_test "standard" "true" "never"
}

configure_disabled_logging() {
    configure_logging_test "minimal" "false" "never"
}

# Set test configuration with specific log level
# Usage: configure_logging_with_level "minimal" "true" "never" "TRACE"
configure_logging_with_level() {
    local format="${1:-minimal}"
    local enabled="${2:-true}"
    local color="${3:-never}"
    local level="${4:-INFO}"
    export LOG_FORMAT="$format"
    export LOG_ENABLED="$enabled"
    export LOG_COLOR="$color"
    export LOG_LEVEL="$level"
}

# =============================================================================
# NESTED SCRIPT GENERATION HELPERS (DRY improvements)
# =============================================================================

# Generate a nested script that calls a logging function with standard config
# Usage: create_logging_script "log_info" "test message" "detailed" "TRACE" "true"
create_logging_script() {
    local func_name="${1}"
    local message="${2}"
    local format="${3:-minimal}"
    local level="${4:-INFO}"
    local enabled="${5:-true}"
    
    local script="export LOG_ENABLED=\"$enabled\"
export LOG_LEVEL=\"$level\"
export LOG_FORMAT=\"$format\"
$func_name \"$message\""
    
    create_nested_temp_script_for_logging "$script"
}

# Generate a nested script with a wrapper function (for nested caller testing)
# Usage: create_nested_function_script "log_info" "test message" "detailed" "TRACE" "true"
create_nested_function_script() {
    local func_name="${1}"
    local message="${2}"
    local format="${3:-detailed}"
    local level="${4:-TRACE}"
    local enabled="${5:-true}"
    
    local script="export LOG_ENABLED=\"$enabled\"
export LOG_LEVEL=\"$level\"
export LOG_FORMAT=\"$format\"
log_from_function() {
  $func_name \"$message\"
}
log_from_function"
    
    create_nested_temp_script_for_logging "$script"
}

# Generate a nested script for set_log_level testing
# Usage: create_set_log_level_script "DEBUG" "WARN" "detailed"
create_set_log_level_script() {
    local new_level="${1}"
    local current_level="${2:-WARN}"
    local format="${3:-detailed}"
    
    local script="export LOG_ENABLED=\"true\"
export LOG_LEVEL=\"$current_level\"
export LOG_FORMAT=\"$format\"
set_log_level \"$new_level\""
    
    create_nested_temp_script_for_logging "$script"
}

# Generate a nested script for debug state management
# Usage: create_debug_control_script "enable_debug" "false" "VERB" "detailed"
create_debug_control_script() {
    local command="${1}"  # enable_debug, disable_debug, toggle_debug
    local initial_enabled="${2:-false}"
    local level="${3:-VERB}"
    local format="${4:-detailed}"
    
    local script="export LOG_ENABLED=\"$initial_enabled\"
export LOG_LEVEL=\"$level\"
export LOG_FORMAT=\"$format\"
$command"
    
    create_nested_temp_script_for_logging "$script"
}

# Generate a nested script for stream testing
# Usage: create_stream_test_script "error_stream" "Line 1\\nLine 2\\nLine 3" "minimal" "true"
create_stream_test_script() {
    local stream_func="${1}"  # log_stream or error_stream
    local content="${2}"
    local format="${3:-minimal}"
    local enabled="${4:-true}"
    
    local script="export LOG_FORMAT=\"$format\"
export LOG_ENABLED=\"$enabled\"
$stream_func <<< \$'$content'"
    
    create_nested_temp_script_for_logging "$script"
}
