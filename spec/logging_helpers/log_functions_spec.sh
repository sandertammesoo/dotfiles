#shellcheck shell=sh

# ============================================================================
# Core Logging Functions Tests for helpers_logging.zsh
# ============================================================================
# This file tests the core logging functions and output streams:
# - _log: Internal logging function with level-based filtering
# - log_trace/debug/info/warn/error/fatal: Level-specific logging functions
# - log_success/log_failure: Specialized logging functions
# - always: Function to bypass LOG_ENABLED checks
# - log_stream/error_stream: Stream processing functions
#
# Tests cover:
# - Message filtering based on log level and LOG_ENABLED
# - Format variations (minimal, standard, detailed)
# - Caller information in detailed format
# - Color code application
# - Stream routing (stdout vs stderr)
# ============================================================================

Describe 'helpers_logging.zsh - Core Logging Functions'
  Include "$SHELLSPEC_SPECDIR/spec_helper.sh"

  Describe '_log'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should log messages correctly based on level and LOG_ENABLED'
      BeforeEach 'source_with_loglevel_info'

      Context 'should log messages when conditions allow'
        # Parameters: msg_level, formatted_level, log_level, enabled, stream, description
        # - msg_level: The level passed to _log (e.g., "INFO", "DEBUG")
        # - formatted_level: The level as it appears in output (e.g., "INFO ", "DEBUG")
        # - log_level: The LOG_LEVEL setting (e.g., "INFO", "DEBUG", "TRACE")
        # - enabled: The LOG_ENABLED setting ("true" or "false")
        # - stream: Expected output stream ("output", "error")
        # - description: Human-readable test case description
        Parameters
          "INFO"  "INFO " "INFO"  "true"  "output" "log INFO message when LOG_LEVEL is INFO and LOG_ENABLED is true"
          "DEBUG" "DEBUG" "DEBUG" "true"  "output" "log DEBUG message when LOG_LEVEL is DEBUG and LOG_ENABLED is true"
          "TRACE" "TRACE" "TRACE" "true"  "output" "log TRACE message when LOG_LEVEL is TRACE and LOG_ENABLED is true"
          "ERROR" "ERROR" "INFO"  "false" "error"  "log ERROR message when LOG_ENABLED is false"
          "FATAL" "FATAL" "INFO"  "true"  "error"  "log FATAL message regardless of LOG_LEVEL when LOG_ENABLED is true"
          "ERROR" "ERROR" "WARN"  "true"  "error"  "log ERROR message regardless of LOG_LEVEL when LOG_ENABLED is true"
          "DEBUG" "DEBUG" "VERB"  "true"  "output" "log DEBUG message when LOG_LEVEL is VERB and LOG_ENABLED is true"
        End

        It "should $6"
          # Configure logging based on parameters
          configure_logging_with_level "minimal" "$4" "never" "$3"
          
          # Call _log with the specified level and message
          When call _log "$1" "This is a $(echo $1 | tr '[:upper:]' '[:lower:]') message."
          The status should be success
          
          # Check expected output stream
          The $5 should include "[$2]"
          The $5 should include "This is a $(echo $1 | tr '[:upper:]' '[:lower:]') message."
        End
      End

      Context 'should not log messages when conditions prevent it'
        # Parameters: msg_level, log_level, enabled, description
        # - msg_level: The level passed to _log (e.g., "DEBUG")
        # - log_level: The LOG_LEVEL setting (e.g., "INFO")
        # - enabled: The LOG_ENABLED setting ("true" or "false")
        # - description: Human-readable test case description
        Parameters
          "DEBUG" "INFO"  "true"  "not log DEBUG message when LOG_LEVEL is INFO and LOG_ENABLED is true"
          "INFO"  "INFO"  "false" "not log INFO message when LOG_ENABLED is false"
          "TRACE" "DEBUG" "true"  "not log TRACE message when LOG_LEVEL is DEBUG and LOG_ENABLED is true"
        End

        It "should $4"
          # Configure logging based on parameters
          configure_logging_with_level "minimal" "$3" "never" "$2"
          
          # Call _log with the specified level and message
          When call _log "$1" "This is a $(echo $1 | tr '[:upper:]' '[:lower:]') message."
          The status should be success
          The output should equal ''
        End
      End
    End
  End

  Describe 'log functions (log_trace, log_debug, log_info, log_warn, log_error, log_fatal)'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should log messages at appropriate levels'
      BeforeEach 'source_with_loglevel_trace'

      # Parameters: function_name, log_level, formatted_level, test_message, stream
      # - function_name: The logging function to test (e.g., log_trace)
      # - log_level: The severity level for filtering checks (e.g., TRACE)
      # - formatted_level: The level name as it appears in output (e.g., TRACE)
      # - test_message: The message text to log
      # - stream: The expected output stream (output or error)
      Parameters
        'log_trace' 'TRACE' 'TRACE' 'This is a trace message.' 'output' ''
        'log_debug' 'DEBUG' 'DEBUG' 'This is a debug message.' 'output' ''
        'log_info'  'INFO'  'INFO '  'This is an info message.' 'output' ''
        'log_warn'  'WARN'  'WARN '  'This is a warning message.' 'output' ' !  '
        'log_error' 'ERROR' 'ERROR' 'This is an error message.' 'error' ''
        'log_fatal' 'FATAL' 'FATAL' 'This is a fatal message.' 'error' ''
      End

      It "should log message with $1 at $2 level"
        export LOG_FORMAT="minimal"
        export LOG_ENABLED="true"
        export LOG_COLOR="never"
        When call "$1" "$4"
        The status should be success
        The line 1 of $5 should include "[$3]"
        The line 1 of $5 should include "$6"
        The line 1 of $5 should include "$4"
      End

      It "should not log $2 message when LOG_LEVEL is higher than $2"
        configure_minimal_logging
        # Set LOG_LEVEL to one level higher than the function being tested
        # Using helper function to avoid duplicating level hierarchy knowledge
        export LOG_LEVEL="$(get_higher_log_level "$2")"
        When call "$1" "$4"
        The status should be success
        The output should equal ''
        # ERROR and FATAL go to stderr, others to stdout
        if [ "$2" = "ERROR" ] || [ "$2" = "FATAL" ]; then
          The error should include "[$3] $4"
        fi
      End

      It "should not log $2 message when LOG_ENABLED is false"
        configure_disabled_logging
        When call "$1" "$4"
        The status should be success
        # ERROR and FATAL still log to stderr even when disabled
        if [ "$5" = "error" ]; then
          The $5 should include "[$3] $4"
        else
          The output should equal ''
          The error should equal ''
        fi
      End
    End

    Context 'should format messages correctly'
      BeforeEach 'source_with_loglevel_trace'

      # Reduced parameter set for format testing (1 stdout + 1 stderr level)
      Parameters
        'log_info'  'INFO'  'INFO '  'This is an info message.' 'output'
        'log_error' 'ERROR' 'ERROR' 'This is an error message.' 'error'
      End

      It "should log $2 message with correct formatting when LOG_FORMAT is detailed"
        configure_logging_with_level "detailed" "true" "never" "TRACE"
        When call "$1" "$4"
        The status should be success
        # Check appropriate stream and verify detailed format elements
        The $5 should include "[$3]"
        The $5 should include "$4"
        The $5 should match pattern '*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*'
      End

      It "should log $2 message with correct formatting when LOG_FORMAT is standard"
        configure_logging_with_level "standard" "true" "never" "TRACE"
        When call "$1" "$4"
        The status should be success
        The $5 should include "[$3] $4"
      End
    End

    Context 'should handle caller information correctly'
      BeforeEach 'source_with_loglevel_trace'

      # Reduced parameter set for caller info testing (just 1 level)
      Parameters
        'log_info'  'INFO'  'INFO '  'This is an info message.' 'output'
      End

      It "should include caller info in $2 message when LOG_FORMAT is detailed"
        configure_logging_with_level "detailed" "true" "never" "TRACE"
        When run create_logging_script "$1" "$4" "detailed" "TRACE" "true"
        The status should be success
        The output should match pattern '*../to/file/calling_script.*.sh:*'
      End

      It "should not include caller info in $2 message when LOG_FORMAT is standard"
        configure_logging_with_level "standard" "true" "never" "TRACE"
        When run create_logging_script "$1" "$4" "standard" "TRACE" "true"
        The status should be success
        The output should not match pattern '*../to/file/calling_script.*.sh:*'
      End

      It "should not include caller info in $2 message when LOG_FORMAT is minimal"
        configure_logging_with_level "minimal" "true" "never" "TRACE"
        When run create_logging_script "$1" "$4" "minimal" "TRACE" "true"
        The status should be success
        The output should not match pattern '*../to/file/calling_script.*.sh:*'
      End

      It "should show the relative path of the invoking script and line number in $2 output when called from another function"
        # This test verifies that get_caller_info() truncates long paths
        # to show only the last 3 directory levels for readability
        # e.g., ../../../../tmp/xyz/long/path/to/file/script.sh → ../to/file/script.sh
        export LOG_COLOR="never"
        When run create_nested_function_script "$1" "$4" "detailed" "TRACE" "true"
        The status should be success
        The output should include "[$3] $4"
        The output should match pattern '*../to/file/calling_script.*.sh:*'
        The output should match pattern '*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*'
      End
    End

    Context 'should apply color codes correctly'
      BeforeEach 'source_with_loglevel_trace'

      # Reduced parameter set for color testing (1 stdout + 1 stderr level)
      Parameters
        'log_info'  'INFO'  'INFO '  'This is an info message.' 'output'
        'log_error' 'ERROR' 'ERROR' 'This is an error message.' 'error'
      End

      It "should log $2 message with color codes when LOG_COLOR is always"
        configure_logging_with_level "minimal" "true" "always" "TRACE"
        export LOG_COLOR="always"
        When call "$1" "$4"
        The status should be success
        # Check for ANSI escape codes and content in appropriate stream
        The $5 should include $'\033['  # ANSI escape code start
        The $5 should include "[$3]"
        The $5 should include "$4"
      End
    End
  End

  Describe 'log_success'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    It 'should log success message at INFO level'
      source_with_loglevel_info
      export LOG_FORMAT="minimal"
      export LOG_ENABLED="true"
      When call log_success "Operation completed successfully."
      The status should be success
      The output should include "[INFO ]  ✔︎  Operation completed successfully."
    End
  End

  Describe 'log_failure'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    It 'should log failure message at ERROR level'
      source_with_loglevel_info
      export LOG_FORMAT="minimal"
      export LOG_ENABLED="true"
      When call log_failure "Operation failed."
      The status should be success
      The error should include "[ERROR]  ✘  Operation failed."
    End
  End

  Describe 'always'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should always log messages regardless of LOG_ENABLED'
      BeforeEach 'source_with_loglevel_info'
      always_caller_test='l_always log_info "This message should always be logged."'

      Parameters
        'true'
        'false'
      End

      It "should log message when LOG_ENABLED is $1"
        export LOG_FORMAT="minimal"
        export LOG_ENABLED="$1"
        When run create_nested_temp_script_for_logging "$always_caller_test"
        The status should be success
        The output should include "[INFO ] This message should always be logged."
      End
    End
  End

  Describe 'log_stream'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should log each line from input stream'
      BeforeEach 'source_with_loglevel_info'

      It 'should log lines from echo input'
        configure_minimal_logging
        When run create_stream_test_script "log_stream \"INFO\"" "Line one of log.\\nLine two of log.\\nLine three of log." "minimal" "true"
        The status should be success
        The line 1 of output should include "[INFO ] Line one of log."
        The line 2 of output should include "[INFO ] Line two of log."
        The line 3 of output should include "[INFO ] Line three of log."
      End

      It 'should not log lines when LOG_ENABLED is false'
        configure_disabled_logging
        When run create_stream_test_script "log_stream \"INFO\"" "Line one of log.\\nLine two of log.\\nLine three of log." "minimal" "false"
        The status should be success
        The output should equal ''
      End
    End
  End

  Describe 'error_stream'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should log each line from error stream'
      BeforeEach 'source_with_loglevel_info'

      It 'should log lines from echo input'
        configure_minimal_logging
        When run create_stream_test_script "error_stream" "Line one of error.\\nLine two of error.\\nLine three of error." "minimal" "true"
        The status should be success
        The line 1 of output should include "[ERROR] Line one of error."
        The line 2 of output should include "[ERROR] Line two of error."
        The line 3 of output should include "[ERROR] Line three of error."
      End

      It 'should log lines when LOG_ENABLED is false'
        configure_disabled_logging
        When run create_stream_test_script "error_stream" "Line one of error.\\nLine two of error.\\nLine three of error." "minimal" "false"
        The status should be success
        The line 1 of output should include "[ERROR] Line one of error."
        The line 2 of output should include "[ERROR] Line two of error."
        The line 3 of output should include "[ERROR] Line three of error."
      End
    End
  End
End
