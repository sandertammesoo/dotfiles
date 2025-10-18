#shellcheck shell=sh

# ============================================================================
# Output Stream Tests for helpers_logging.zsh
# ============================================================================
# This file tests the output_stream function which processes piped command
# output through the logging system with special handling for:
# - ANSI color code preservation
# - Multi-line colored blocks with color continuity
# - Individual timestamps and prefixes for each line
# - Reset sequence detection to clear active colors
# - Non-detailed format (no caller info)
#
# Note: output_stream is tested primarily through integration tests and
# manual verification due to complexity of testing piped input in nested
# script contexts. These tests verify the function exists and basic behavior.
# ============================================================================

Describe 'helpers_logging.zsh - output_stream Function'
  Include "$SHELLSPEC_SPECDIR/spec_helper.sh"

  Describe 'output_stream'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'function existence and basic behavior'
      BeforeEach 'source_with_loglevel_info'

      It 'should be defined as a function'
        configure_minimal_logging
        When call type output_stream
        The status should be success
        The output should include "function"
      End

      It 'should accept OUTPUT level by default (no parameter required)'
        configure_minimal_logging
        # Verify function accepts piped input without arguments
        test_script='echo "test" | output_stream >/dev/null 2>&1; echo $?'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        The output should include "0"
      End

      It 'should accept custom log levels as optional parameter'
        configure_minimal_logging
        # Verify function accepts log level parameter
        test_script='echo "test" | output_stream DEBUG >/dev/null 2>&1; echo $?'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        The output should include "0"
      End
    End

    Context 'LOG_ENABLED behavior'
      BeforeEach 'source_with_loglevel_info'

      It 'should respect LOG_ENABLED for non-ERROR levels'
        configure_disabled_logging
        test_script='echo "Test" | output_stream INFO'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        # INFO level should not log when LOG_ENABLED is false
        The output should not include "Test"
      End

      It 'should always log ERROR level regardless of LOG_ENABLED'
        configure_disabled_logging
        test_script='echo "Error" | output_stream ERROR'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        The output should include "[ERROR]"
        The output should include "Error"
      End
    End

    Context 'integration with logging framework'
      BeforeEach 'source_with_loglevel_info'

      It 'should use output_stream format (no caller info)'
        configure_logging_test "detailed" "true" "never"
        test_script='
export LOG_FORMAT="detailed"
export LOG_ENABLED="true"
export LOG_LEVEL="DEBUG"
echo "StreamTestUnique" | output_stream
log_info "RegularTestUnique"
'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        # output_stream line should not have caller info - check for [ ... ] marker
        The output should include "StreamTestUnique"
        The output should include " ... "
        # Regular log should have caller info
        The output should match pattern '*RegularTestUnique*.sh:[0-9]*'
      End

      It 'should restore LOG_FORMAT after processing'
        configure_logging_test "detailed" "true" "never"
        test_script='
export LOG_FORMAT="detailed"
export LOG_ENABLED="true"
export LOG_LEVEL="DEBUG"
echo "FirstTestUnique" | output_stream
log_info "AfterTestUnique"
'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        The output should include "FirstTestUnique"
        The output should include "AfterTestUnique"
        # Verify detailed format is restored (has caller info)
        The output should match pattern '*AfterTestUnique*.sh:[0-9]*'
      End

      It 'should restore LOG_COLOR after processing'
        configure_logging_test "minimal" "true" "never"
        test_script='
export LOG_COLOR="never"
export LOG_ENABLED="true"
export LOG_LEVEL="DEBUG"
printf "\\x1b[32mColoredTestUnique\\x1b[0m\\n" | output_stream
log_info "PlainTestUnique"
'
        When run create_nested_temp_script_for_logging "$test_script"
        The status should be success
        The output should include "ColoredTestUnique"
        The output should include "PlainTestUnique"
        # Verify LOG_COLOR=never is respected for regular log (no ANSI codes)
        The output should not match pattern '*PlainTestUnique.*\x1b\[*'
      End
    End
  End
End
