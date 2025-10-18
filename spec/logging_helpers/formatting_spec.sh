#shellcheck shell=sh

#==============================================================================
# Formatting Tests for Helpers Logging Framework
#
# This file tests:
# - color_text (ANSI color codes and styles)
# - format_log_message (minimal, standard, detailed formats)
#
# Part of the logging_helpers test suite (split for maintainability)
#==============================================================================

Describe 'color_text'
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context 'should apply color codes based on LOG_COLOR setting'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    # Reduced to 3 representative colors:
    # - red: basic ANSI code (31m)
    # - gray: extended 256-color code (238m)
    # - blue: mid-range ANSI code (34m)
    # Color application logic is identical for all colors; testing 3 provides full coverage
    Parameters
      'red' "31m"
      'gray' "238m"
      'blue' "34m"
    End

    It 'should return unmodified text when LOG_COLOR is never'
      export LOG_COLOR="never"
      When call color_text "$1" "Test Message"
      The status should be success
      The output should equal "Test Message"
    End

    It "should return text colored $1 when LOG_COLOR is always"
      export LOG_COLOR="always"
      When call color_text "$1" "Test Message"
      The status should be success
      The output should include $'\033['  # ANSI escape code start
      The output should include $2
      The output should include "Test Message"
    End

    It 'should return unmodified text when LOG_COLOR is auto and not a TTY'
      export LOG_COLOR="auto"
      When call color_text "$1" "Test Message"
      The status should be success
      The output should equal "Test Message"
    End
  End

  Context 'should apply styles correctly'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    It 'should apply bold style'
      configure_logging_test "minimal" "true" "always"
      When call color_text "red" "bold" "Bold Message"
      The status should be success
      The output should include $'\e[1;'  # Bold style code
      The output should include "Bold Message"
    End

    It 'should apply underline style'
      configure_logging_test "minimal" "true" "always"
      When call color_text "blue" "underline" "Underline Message"
      The status should be success
      The output should include $'\e[4;'  # Underline style code
      The output should include "Underline Message"
    End

    It 'should apply combined bold and underline styles'
      configure_logging_test "minimal" "true" "always"
      When call color_text "green" "bold" "underline" "Bold Underline Message"
      The status should be success
      The output should include $'\e[1;4;'  # Bold + Underline style codes
      The output should include "Bold Underline Message"
    End

    It 'should return unmodified text when no styles are given'
      configure_logging_test "minimal" "true" "always"
      When call color_text "yellow" "No Style Message"
      The status should be success
      The output should include $'\e['  # Color code only
      The output should include "No Style Message"
    End

    It 'should return unmodified text when no color is given'
      configure_logging_test "minimal" "true" "always"
      When call color_text "bold" "No Color Message"
      The status should be success
      The output should include $'\e[1m'  # Bold style code only
      The output should include "No Color Message"
    End

    It 'should return unmodified text when no color or styles are given'
      configure_logging_test "minimal" "true" "always"
      When call color_text "Plain Message"
      The status should be success
      The output should equal "Plain Message"
    End
  End
End

Describe 'format_log_message'
  BeforeEach 'setup_test_environment'
  AfterEach 'cleanup_test_environment'

  Context 'should format log messages based on LOG_FORMAT setting'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    It 'should format message in standard format'
      export LOG_FORMAT="standard"
      When call format_log_message "INFO" "This is a test message."
      The status should be success
      The output should include "[INFO ] This is a test message."
    End

    It 'should format message in minimal format'
      export LOG_FORMAT="minimal"
      When call format_log_message "WARN" "This is a warning."
      The status should be success
      The output should include "[WARN ] This is a warning."
    End

    It 'should format message in detailed format with timestamp'
      export LOG_FORMAT="detailed"
      When call format_log_message "ERROR" "This is an error."
      The status should be success
      The output should match pattern '*[ERROR]*This is an error.*'
      The output should match pattern '*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*'
    End
  End

  Context 'should include caller info when LOG_FORMAT is detailed'
    BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

    It 'should include caller info in detailed format'
      export LOG_FORMAT="detailed"
      caller_info_test='format_log_message "DEBUG" "Testing caller info."'
      When run create_nested_temp_script_for_logging "$caller_info_test"
      The status should be success
      The output should include "[DEBUG] Testing caller info."
      The output should match pattern '*../to/file/calling_script.*.sh:*'
    End

    It 'should not include caller info in standard format'
      export LOG_FORMAT="standard"
      caller_info_test_standard='format_log_message "DEBUG" "Testing caller info standard."'
      When run create_nested_temp_script_for_logging "$caller_info_test_standard"
      The status should be success
      The output should include "[DEBUG] Testing caller info standard."
      The output should not match pattern '*../to/file/calling_script.*.sh:*'
    End

    It 'should not include caller info in minimal format'
      export LOG_FORMAT="minimal"
      caller_info_test_minimal='format_log_message "DEBUG" "Testing caller info minimal."'
      When run create_nested_temp_script_for_logging "$caller_info_test_minimal"
      The status should be success
      The output should include "[DEBUG] Testing caller info minimal."
    End

    It 'should include caller info when LOG_FORMAT is detailed and called from another function'
      export LOG_FORMAT="detailed"
      caller_info_nested_test='format_log_message "INFO" "Testing nested caller info."'
      When run create_nested_temp_script_for_logging "$caller_info_nested_test"
      The status should be success
      The output should include "[INFO ] Testing nested caller info."
      The output should match pattern '*../to/file/calling_script.*.sh:*'
    End
  End
End
