#shellcheck shell=sh

# ============================================================================
# Utility Functions Tests for helpers_logging.zsh
# ============================================================================
# This file tests utility helper functions:
# - try_source: Safely source a file if it exists
# - _export_n_log: Export variables with validation
# - add_to: Add paths to environment variables without duplicates
#
# Tests cover:
# - Existing vs non-existing files
# - Valid vs invalid variable assignments
# - Duplicate path handling
# - Empty variable initialization
# ============================================================================

Describe 'helpers_logging.zsh - Utilities'
  Include "$SHELLSPEC_SPECDIR/spec_helper.sh"

  Describe 'try_source'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'
    Context 'should source file if it exists, else do nothing'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should source existing file successfully'
        temp_dir=$(mktemp -d)
        script_path="$temp_dir/existing_script.sh"
        echo 'export TEST_VAR="sourced"' > "$script_path"
        When call try_source "$script_path"
        The status should be success
        The variable TEST_VAR should equal "sourced"
        rm -rf "$temp_dir"
      End

      It 'should handle non-existing file gracefully'
        temp_dir=$(mktemp -d)
        script_path="$temp_dir/non_existing_script.sh"
        When call try_source "$script_path"
        The status should be success
        The variable TEST_VAR should be undefined
        rm -rf "$temp_dir"
      End
    End
  End

  Describe '_export_n_log'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should export variable without logging'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should export variable successfully'
        When call _export_n_log "TEST_EXPORT_VAR=exported_value"
        The status should be success
        The variable TEST_EXPORT_VAR should equal "exported_value"
      End

      It 'should handle invalid assignment gracefully'
        When call _export_n_log "INVALID_ASSIGNMENT"
        The status should be failure
        The error should include "Invalid assignment: INVALID_ASSIGNMENT. Use VAR=VALUE format."
      End
    End
  End

  Describe 'add_to'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should add paths to environment variable without duplicates'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should add new paths to PATH variable'
        export PATH="/usr/bin:/bin"
        When call add_to PATH "/usr/local/bin" "/opt/bin"
        The status should be success
        The variable PATH should equal "/usr/local/bin:/opt/bin:/usr/bin:/bin"
      End

      It 'should not add duplicate paths to PATH variable'
        export PATH="/usr/local/bin:/usr/bin:/bin"
        When call add_to PATH "/usr/local/bin" "/opt/bin"
        The status should be success
        The variable PATH should equal "/opt/bin:/usr/local/bin:/usr/bin:/bin"
      End

      It 'should handle empty PATH variable'
        unset PATH
        When call add_to PATH "/usr/local/bin" "/opt/bin"
        The status should be success
        The variable PATH should equal "/usr/local/bin:/opt/bin"
      End
    End
  End
End
