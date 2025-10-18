#shellcheck shell=sh

#==============================================================================
# Configuration Tests for Helpers Logging Framework
#
# This file tests:
# - _set_log_level (silent internal function)
# - set_log_level (user-facing function with debug output)
# - print_log_level (query current level)
# - is_debug_enabled (check debug state)
#
# Part of the logging_helpers test suite (split for maintainability)
#==============================================================================

Describe 'Configuration Functions'
  # Setup and cleanup for tests that need sourced framework
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context '_set_log_level'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    It 'should quietly allow setting custom log level'
      When call _set_log_level "TRACE"
      The status should be success
      The variable LOG_LEVEL should equal "TRACE"
      The output should equal ''
    End

    It 'should quietly reject invalid log level and remain unchanged'
      When call _set_log_level "INVALID"
      The status should be failure
      The variable LOG_LEVEL should equal "INFO"
      The output should equal ''
      The stderr should equal ''
    End
  End

  Context 'set_log_level'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    Context 'with debugging disabled'
      Context 'should set each log level successfully when debugging is disabled'

        Parameters
          'TRACE'
          'VERB'
          'DEBUG'
          'INFO'
          'WARN'
          'ERROR'
          'FATAL'
        End

        It "should set log level to $1 without debug output"
          When call set_log_level "$1"
          The status should be success
          The variable LOG_LEVEL should equal "$1"
          The output should equal ''
          The stderr should equal ''
        End
      End
    End

    Context 'invalid log level handling'
      # Test that invalid log levels are rejected in all states
      # and that the current log level remains unchanged
      
      Parameters
        'false' 'INFO'   # debugging disabled, default level
        'true' 'WARN'    # debugging enabled, high level (INFO or higher)
        'true' 'VERB'    # debugging enabled, low level (DEBUG or lower)
      End

      It "should reject invalid level and remain at $2 when LOG_ENABLED=$1"
        export LOG_ENABLED="$1"
        export LOG_LEVEL="$2"
        When call set_log_level "INVALID"
        The status should be failure
        The variable LOG_LEVEL should equal "$2"
        # Verify error message format and content
        The stderr should match pattern '*Invalid log level*INVALID*'
      End
    End

    Context 'with debugging enabled and log level set to INFO or higher'
      # When current level > DEBUG (INFO, WARN, ERROR, FATAL):
      # - Should log debug output ONLY when setting to TRACE, VERB, or DEBUG
      # - Should NOT log when setting to INFO or higher levels
      logenabled_with_warn() {
          export LOG_ENABLED="true"
          export LOG_LEVEL="WARN"
        }
      BeforeEach 'logenabled_with_warn'

      Context 'should set valid log level with debug output for lower levels'
        Parameters
          'TRACE' 'Log level set to TRACE'
          'VERB' 'Log level set to VERB'
          'DEBUG' 'Log level set to DEBUG'
        End

        It "should change log level from WARN to $1 and output debug message"
          When call set_log_level "$1"
          The status should be success
          The variable LOG_LEVEL should equal "$1"
          The output should include "$2"
          The stderr should equal ''
        End
      End

      Context 'should set valid log level without debug output for higher levels'
        Parameters
          'INFO'
          'WARN'
          'ERROR'
          'FATAL'
        End

        It "should change log level from WARN to $1 without debug output"
          When call set_log_level "$1"
          The status should be success
          The variable LOG_LEVEL should equal "$1"
          The output should equal ''
          The stderr should equal ''
        End
      End

      It 'should log debug message when changing from INFO to DEBUG (boundary case)'
        # This explicitly tests the boundary: INFO (3) to DEBUG (2)
        # Since INFO > DEBUG threshold, setting to DEBUG should use 'always'
        # but we're testing from INFO, not WARN, to verify boundary behavior
        export LOG_ENABLED="true"
        export LOG_LEVEL="INFO"
        When call set_log_level "DEBUG"
        The status should be success
        The variable LOG_LEVEL should equal "DEBUG"
        The output should include "[DEBUG]"
        The output should include "Log level set to DEBUG"
        The stderr should equal ''
      End
    End

    Context 'with debugging enabled and log level set to DEBUG or lower'
      # When current level <= DEBUG (TRACE, VERB, DEBUG):
      # - Should log debug output for ALL level changes
      # - This is because the current level allows DEBUG messages to be shown
      logenabled_with_verb() {
          export LOG_ENABLED="true"
          export LOG_LEVEL="VERB"
        }
      BeforeEach 'logenabled_with_verb'
      
      Context 'should set valid log level with debug output for all levels'
        Parameters
          'TRACE' 'Log level set to TRACE'
          'VERB' 'Log level set to VERB'
          'DEBUG' 'Log level set to DEBUG'
          'INFO' 'Log level set to INFO'
          'WARN' 'Log level set to WARN'
          'ERROR' 'Log level set to ERROR'
          'FATAL' 'Log level set to FATAL'
        End

        It "should change log level from VERB to $1 and output debug message"
          When call set_log_level "$1"
          The status should be success
          The variable LOG_LEVEL should equal "$1"
          The output should include "[DEBUG]"
          The output should include "$2"
          The stderr should equal ''
        End
      End

      It 'should show the relative path of the invoking script and line number in debug output'
        # This test verifies that get_caller_info() truncates long paths
        # to show only the last 3 directory levels for readability
        # e.g., ../../../../tmp/xyz/long/path/to/file/script.sh → ../to/file/script.sh
        When run create_set_log_level_script "DEBUG" "VERB" "detailed"
        The status should be success
        The output should include "[DEBUG]"
        # Use flexible pattern matching for path components
        The output should match pattern '*calling_script.*.sh:*'
        The output should match pattern '*/file/*'
        The output should match pattern '*:[0-9]*'
        The stderr should equal ''
      End
    End
  End
End

Describe 'print_log_level'
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context 'should return current log level correctly'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    Parameters
      'TRACE'
      'VERB'
      'DEBUG'
      'INFO'
      'WARN'
      'ERROR'
      'FATAL'
    End

    It "should return $1 when LOG_LEVEL is set to $1"
      export LOG_LEVEL="$1"
      When call print_log_level
      The status should be success
      The output should equal "$1"
    End
  End
End

Describe 'is_debug_enabled'
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context 'should correctly reflect debug enabled state'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    Parameters
      'false' 'INFO' 1  # debugging disabled, default level
      'false' 'WARN' 1  # debugging disabled, high level (INFO or higher)
      'true'  'VERB' 0  # debugging enabled, low level (DEBUG or lower)
      'true'  'DEBUG' 0  # debugging enabled, low level (DEBUG or lower)
      'false' 'INFO' 1  # debugging disabled, high level (INFO or higher)
      'false' 'ERROR' 1  # debugging disabled, high level (INFO or higher)
    End

    It "should return $1 when LOG_ENABLED=$1 and LOG_LEVEL=$2"
      export LOG_ENABLED="$1"
      export LOG_LEVEL="$2"
      When call is_debug_enabled
      The status should equal "$3"
    End
  End
End
