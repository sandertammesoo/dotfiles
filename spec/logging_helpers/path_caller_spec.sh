#shellcheck shell=sh

# ============================================================================
# Path and Caller Info Tests for helpers_logging.zsh
# ============================================================================
# This file tests path conversion and caller information tracking functions:
# - to_relative: Converts absolute paths to relative paths
# - get_caller_info: Tracks and formats call stack information
#
# Tests cover edge cases like:
# - Same directory, parent directories, symbolic links
# - Paths with spaces and special characters
# - Root directory and home directory handling
# - Deep call stacks and sourced scripts
# ============================================================================

Describe 'helpers_logging.zsh - Path & Caller Info'
  Include "$SHELLSPEC_SPECDIR/spec_helper.sh"

  Describe 'to_relative'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should convert paths to relative paths correctly'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should convert absolute path to relative path'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        When call to_relative "$temp_dir"
        The status should be success
        The output should equal "../../../"
        rm -rf "$temp_dir"
      End

      It 'should return relative path unchanged'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        When call to_relative "../d/e/f"
        The status should be success
        The output should equal "../d/e/f"
        rm -rf "$temp_dir"
      End

      It 'should handle current directory path'
        temp_dir=$(mktemp -d)
        builtin cd "$temp_dir" || return 1
        When call to_relative "."
        The status should be success
        The output should equal "."
        rm -rf "$temp_dir"
      End

      It 'should handle parent directory path'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        When call to_relative "../.."
        The status should be success
        The output should equal "../.."
        rm -rf "$temp_dir"
      End

      It 'should handle non-existent target paths'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        # Calculate expected number of ../ based on actual PWD depth
        pwd_depth=$(echo "$PWD" | tr -cd '/' | wc -c | tr -d ' ')
        expected_updirs=$(printf '../%.0s' $(seq 1 $pwd_depth))
        When call to_relative "/non/existent/path"
        The status should be success
        The output should equal "${expected_updirs}non/existent/path"
        rm -rf "$temp_dir"
      End

      It 'should handle paths with spaces correctly'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a b/c d"
        builtin cd "$temp_dir/a b/c d" || return 1
        When call to_relative "$temp_dir"
        The status should be success
        The output should equal "../../"
        rm -rf "$temp_dir"
      End

      It 'should handle paths with special characters correctly'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a@b/c#d"
        builtin cd "$temp_dir/a@b/c#d" || return 1
        When call to_relative "$temp_dir"
        The status should be success
        The output should equal "../../"
        rm -rf "$temp_dir"
      End

      It 'should handle symbolic links correctly'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/real/dir"
        ln -s "$temp_dir/real/dir" "$temp_dir/link_to_dir"
        builtin cd "$temp_dir/link_to_dir" || return 1
        When call to_relative "$temp_dir"
        The status should be success
        The output should equal "../"
        rm -rf "$temp_dir"
      End

      It 'should handle root directory correctly'
        temp_dir=$(mktemp -d)
        builtin cd "$temp_dir" || return 1
        # Calculate expected number of ../ based on actual PWD depth to get to root
        pwd_depth=$(echo "$PWD" | tr -cd '/' | wc -c | tr -d ' ')
        expected_result=$(printf '../%.0s' $(seq 1 $pwd_depth))
        When call to_relative "/"
        The status should be success
        The output should equal "$expected_result"
        rm -rf "$temp_dir"
      End

      It 'should handle home directory paths correctly'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        home_dir="$temp_dir"
        When call to_relative "$home_dir"
        The status should be success
        The output should equal "../../../"
        rm -rf "$temp_dir"
      End

      It 'should handle mixed absolute and relative paths correctly'
        temp_dir=$(mktemp -d)
        mkdir -p "$temp_dir/a/b/c"
        builtin cd "$temp_dir/a/b/c" || return 1
        # Calculate expected number of ../ based on actual PWD depth
        pwd_depth=$(echo "$PWD" | tr -cd '/' | wc -c | tr -d ' ')
        expected_updirs=$(printf '../%.0s' $(seq 1 $pwd_depth))
        When call to_relative "/etc/hosts"
        The status should be success
        The output should equal "${expected_updirs}etc/hosts"
        rm -rf "$temp_dir"
      End
    End
  End

  Describe 'get_caller_info'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'should return caller info correctly'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should return correct caller info from direct call'
        test_caller_info='get_caller_info'
        When run create_nested_temp_script_for_logging "$test_caller_info"
        The status should be success
        The output should match pattern '*../to/file/calling_script.*.sh:*'
      End

      It 'should return correct caller info from nested function call'
        test_nested_caller_info='nested_function() {
  get_caller_info
}
nested_function'
        When run create_nested_temp_script_for_logging "$test_nested_caller_info"
        The status should be success
        The output should match pattern '*../to/file/calling_script.*.sh:*'
      End

      It 'should handle deep call stacks correctly'
        test_deep_caller_info='func_a() {
  func_b
}
func_b() {
  get_caller_info
}
func_a'
        When run create_nested_temp_script_for_logging "$test_deep_caller_info"
        The status should be success
        The output should match pattern '*../to/file/calling_script.*.sh:*'
      End

      It 'should handle calls from sourced scripts correctly'
        test_sourced_caller_info='get_caller_info'
        temp_dir=$(mktemp -d)
        script_path="$temp_dir/calling_script.sh"
        # Source the logging framework first, then call get_caller_info
        # Unset the guard variable to allow sourcing in subprocess
        echo "unset HELPERS_LOGGING_LOADED" > "$script_path"
        echo "source '$SHELLSPEC_SPECDIR/../helpers_logging.zsh'" >> "$script_path"
        echo "$test_sourced_caller_info" >> "$script_path"
        # Use --no-rcs to avoid loading user's .zshenv which may depend on helpers_logging.zsh
        When run zsh --no-rcs -c "source '$script_path'"
        The status should be success
        The output should match pattern '*calling_script.sh:*'
        rm -rf "$temp_dir"
      End
    End
  End
End
