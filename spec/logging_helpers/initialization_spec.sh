#shellcheck shell=sh

#==============================================================================
# Initialization Tests for Helpers Logging Framework
#
# This file tests:
# - Framework loading and guard variables
# - Default variable states
# - Custom variable preservation
# - Double-loading protection
# - Function availability
#
# Part of the logging_helpers test suite (split for maintainability)
#==============================================================================

Describe 'Framework Initialization'

  Context 'before sourcing helpers_logging.zsh'
    # Setup to ensure clean environment
    BeforeEach 'setup_test_environment'

    It 'should not have HELPERS_LOGGING_LOADED variable set'
      The variable HELPERS_LOGGING_LOADED should be undefined
    End

    It 'should not have HELPERS_LOGGING_INITIALIZED variable set'
      The variable HELPERS_LOGGING_INITIALIZED should be undefined
    End

    It 'should not have init_logging function available'
      When call type init_logging
      The status should be failure
      # Different shells have different 'type' output formats
      The output should match pattern "*not found*"
    End
  End

  Context 'after sourcing helpers_logging.zsh'
    # Setup and cleanup for tests that need sourced framework
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'with default variable states'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should have HELPERS_LOGGING_LOADED variable set'
        The variable HELPERS_LOGGING_LOADED should be defined
      End

      It 'should have HELPERS_LOGGING_INITIALIZED variable set'
        The variable HELPERS_LOGGING_INITIALIZED should be defined
      End

      It 'should have LOG_ENABLED variable set to false by default'
        The variable LOG_ENABLED should equal "false"
      End 

      It 'should have LOG_LEVEL variable set to INFO by default'
        The variable LOG_LEVEL should equal "INFO"
      End

      It 'should have LOG_FORMAT variable set to standard by default'
        The variable LOG_FORMAT should equal "standard"
      End
      
      It 'should have LOG_COLOR variable changed from auto after init_logging runs'
        # In test environment (non-TTY), it should be set to "never"
        The variable LOG_COLOR should equal "never"
      End
    End

    Context 'with custom LOG_LEVEL variable'
      It 'should preserve valid LOG_LEVEL set before sourcing'
        When call source_with_loglevel_debug
        The status should be success
        The variable LOG_LEVEL should equal "DEBUG"
      End
        
      It 'should fallback to INFO when invalid LOG_LEVEL set before sourcing'
        source_with_invalid_loglevel() {
          export LOG_LEVEL="INVALID"
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
        }
        When call source_with_invalid_loglevel
        The status should be success
        The variable LOG_LEVEL should equal "INFO"
        The stdout should include "Invalid LOG_LEVEL 'INVALID'"
        The stdout should include "falling back to INFO"
      End
    End

    Context 'with custom LOG_FORMAT variable'
      It 'should preserve LOG_FORMAT set before sourcing'
        source_with_logformat() {
          export LOG_FORMAT="minimal"
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
        }
        When call source_with_logformat
        The status should be success
        The variable LOG_FORMAT should equal "minimal"
      End
    End

    Context 'with custom LOG_COLOR variable'
      It 'should preserve LOG_COLOR set before sourcing'
        source_with_logcolor() {
          export LOG_COLOR="never"
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
        }
        When call source_with_logcolor
        The status should be success
        The variable LOG_COLOR should equal "never"
      End
    End

    Context 'with custom LOG_ENABLED variable'
      It 'should preserve LOG_ENABLED set before sourcing'
        source_with_logenabled() {
          export LOG_ENABLED="true"
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
        }
        When call source_with_logenabled
        The status should be success
        The variable LOG_ENABLED should equal "true"
      End
    End

    Context 'double-loading protection'
      It 'should not reinitialize when sourced twice'
        source_twice() {
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
          export LOG_LEVEL="DEBUG"  # Try to change after first load
          source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
        }
        When call source_twice
        The status should be success
        # Should preserve DEBUG level because guard prevents re-initialization
        # which would otherwise reset to default INFO level
        The variable LOG_LEVEL should equal "DEBUG"
        The variable HELPERS_LOGGING_LOADED should equal "1"
      End
    End

    Context 'available functions'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      Parameters
        'init_logging'
        'set_log_level'
        '_set_log_level'
        'print_log_level'
        'is_debug_enabled'
        'enable_debug'
        'disable_debug'
        'toggle_debug'
        '_enable_debug'
        '_disable_debug'
        '_toggle_debug'
        'color_text'
        'format_log_message'
        'to_relative'
        'get_caller_info'
        '_log'
        'log_trace'
        'log_verbose'
        'log_debug'
        'log_info'
        'log_warn'
        'log_error'
        'log_fatal'
        'log_success'
        'log_failure'
        'log_user'
        'l_always'
        'log_stream'
        'error_stream'
        'try_source'
        'export_n_log'
        '_export_n_log'
        'add_to'
      End

      It "should include $1"
        When call type "$1"
        The status should be success
        The output should include "$1 is a shell function"
      End
    End
  End
End
