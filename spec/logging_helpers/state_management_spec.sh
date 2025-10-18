#shellcheck shell=sh

#==============================================================================
# State Management Tests for Helpers Logging Framework
#
# This file tests:
# - _enable_debug, _disable_debug, _toggle_debug (silent internal functions)
# - enable_debug, disable_debug, toggle_debug (user-facing functions)
# - should_log (log level filtering logic)
#
# Part of the logging_helpers test suite (split for maintainability)
#==============================================================================

Describe 'Debug State Management'
  
  Context '_enable_debug, _disable_debug, _toggle_debug'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should modify LOG_ENABLED state correctly'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      # Parameters: function, initial_state, expected_state, description
      # - function: The debug control function to test
      # - initial_state: Initial LOG_ENABLED value (empty string means default/unset)
      # - expected_state: Expected LOG_ENABLED value after function call
      # - description: Human-readable test case description
      Parameters
        "_enable_debug"  ""      "true"  "enable debug logging"
        "_disable_debug" ""      "false" "disable debug logging from default state"
        "_disable_debug" "true"  "false" "disable debug logging when already enabled"
        "_toggle_debug"  "false" "true"  "toggle debug logging from false to true"
        "_toggle_debug"  "true"  "false" "toggle debug logging from true to false"
      End

      It "should $4"
        # Set initial state if specified
        if [ -n "$2" ]; then
          export LOG_ENABLED="$2"
        fi
        When call "$1"
        The status should be success
        The variable LOG_ENABLED should equal "$3"
      End
    End
  End

  Context 'enable_debug, disable_debug, toggle_debug'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should modify LOG_ENABLED state correctly with user output if LOG_LEVEL allows'
      BeforeEach 'source_with_loglevel_debug'

      Context 'should modify state and show appropriate output'
        # Parameters: function, initial_state, expected_state, expected_output
        # - function: The debug control function to test
        # - initial_state: Initial LOG_ENABLED value
        # - expected_state: Expected LOG_ENABLED value after function call
        # - expected_output: Expected output message (empty string means no output)
        Parameters
          "enable_debug"  "false" "true"  "[DEBUG] Debugging enabled"
          "disable_debug" "false" "false" ""
          "disable_debug" "true"  "false" "[DEBUG] Debugging disabled"
          "toggle_debug"  "false" "true"  "[DEBUG] Debugging enabled"
          "toggle_debug"  "true"  "false" "[DEBUG] Debugging disabled"
        End

        It "should show correct output when calling $1 from LOG_ENABLED=$2"
          export LOG_ENABLED="$2"
          When call "$1"
          The status should be success
          The variable LOG_ENABLED should equal "$3"
          if [ -n "$4" ]; then
            The output should include "$4"
          else
            The output should equal ''
            The stderr should equal ''
          fi
        End
      End

      Context 'should show caller info in debug output'
        It 'should show the relative path of the invoking script and line number in enable_debug output'
            # This test verifies that get_caller_info() truncates long paths
            # to show only the last 3 directory levels for readability
            # e.g., ../../../../tmp/xyz/long/path/to/file/script.sh → ../to/file/script.sh
            When run create_debug_control_script "enable_debug" "false" "VERB" "detailed"
            The status should be success
            The output should include "[DEBUG]"
            The output should match pattern '*../to/file/calling_script.*.sh:*'
            The stderr should equal ''
          End

        It 'should show the relative path of the invoking script and line number in disable_debug output'
            # This test verifies that get_caller_info() truncates long paths
            # to show only the last 3 directory levels for readability
            # e.g., ../../../../tmp/xyz/long/path/to/file/script.sh → ../to/file/script.sh
            When run create_debug_control_script "disable_debug" "true" "VERB" "detailed"
            The status should be success
            The output should include "[DEBUG]"
            The output should match pattern '*../to/file/calling_script.*.sh:*'
            The stderr should equal ''
          End
      End
    End
  End
End

Describe 'should_log'
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context 'should log messages at or above current LOG_LEVEL if LOG_ENABLED is true'
    BeforeEach 'source_with_loglevel_info'

    Context 'should log INFO and higher levels when LOG_LEVEL is INFO'
      Parameters
        'INFO' 0
        'WARN' 0
        'ERROR' 0
        'FATAL' 0
        'DEBUG' 1
        'TRACE' 1
      End

      It "should log $1 when LOG_LEVEL is INFO"
        export LOG_ENABLED="true"
        When call should_log "$1"
        The status should equal "$2"
      End
    End

    Context 'should not log DEBUG or TRACE levels when LOG_LEVEL is INFO'
      Parameters
        'DEBUG' 1
        'TRACE' 1
      End

      It "should not log $1 when LOG_LEVEL is INFO"
        export LOG_ENABLED="true"
        When call should_log "$1"
        The status should equal "$2"
      End
    End

    Context 'should log all levels when LOG_LEVEL is TRACE'
      BeforeEach 'set_log_level "TRACE"'

      Parameters
        'TRACE' 0
        'DEBUG' 0
        'INFO' 0
        'WARN' 0
        'ERROR' 0
        'FATAL' 0
      End

      It "should log $1 when LOG_LEVEL is TRACE"
        export LOG_ENABLED="true"
        When call should_log "$1"
        The status should equal "$2"
      End
    End

    Context 'should not log any levels lower than ERROR when LOG_ENABLED is false'
      Parameters
        'TRACE' 1
        'DEBUG' 1
        'INFO' 1
        'WARN' 1
        'ERROR' 0
        'FATAL' 0
      End

      It "should not log $1 when LOG_ENABLED is false"
        export LOG_ENABLED="false"
        When call should_log "$1"
        The status should equal "$2"
      End
    End
  End 
End
