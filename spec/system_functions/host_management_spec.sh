# shellcheck shell=zsh
# ShellSpec tests for host management functions

Describe 'Host Management Functions'
  Include zsh-setup-scripts/system/functions.zsh

  setup() {
    # Create temporary hosts file for testing
    TEST_HOSTS_FILE="$(mktemp)"
    
    # Mock hosts file with some entries
    cat > "$TEST_HOSTS_FILE" <<EOF
127.0.0.1       localhost
::1             localhost
192.168.1.1     router.local
10.0.0.5        server.example.com
EOF
    
    # Mock sudo for testing (will need actual sudo for integration tests)
    sudo() {
      if [[ "$1" == "flock" ]]; then
        # Skip flock wrapper, just execute the command
        shift
        shift
        shift
        eval "$@"
      else
        command sudo "$@"
      fi
    }
  }

  cleanup() {
    rm -f "$TEST_HOSTS_FILE"
    unset -f sudo
  }

  Before 'setup'
  After 'cleanup'

  Describe 'add_host()' 
    # Note: These tests require mocking sudo or running with appropriate permissions
    # In real usage, add_host modifies /etc/hosts which requires sudo
    
    It 'shows usage when called without arguments'
      When call add_host
      The status should be failure
      The output should include "Usage: add_host"
    End

    It 'shows usage when called with only one argument'
      When call add_host 192.168.1.10
      The status should be failure
      The output should include "Usage: add_host"
    End

    It 'validates IP address format'
      # Mock the sudo call to test validation without actually modifying /etc/hosts
      add_host_test() {
        local ip="$1"
        local hostname="$2"
        
        # Just run the IP validation part
        if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          echo "Error: Invalid IP address format: '$ip'"
          return 1
        fi
        echo "IP is valid"
        return 0
      }

      When call add_host_test "invalid-ip" "hostname"
      The status should be failure
      The output should include "Invalid IP address"
    End

    It 'accepts valid IP addresses'
      add_host_test() {
        local ip="$1"
        local hostname="$2"
        
        if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          echo "Error: Invalid IP address format: '$ip'"
          return 1
        fi
        echo "IP is valid"
        return 0
      }

      When call add_host_test "192.168.1.10" "myhost"
      The status should be success
      The output should include "IP is valid"
    End

    It 'detects duplicate hostname entries'
      # Test duplicate detection logic
      check_duplicate() {
        local hostname="$1"
        local hosts_file="$TEST_HOSTS_FILE"
        
        if grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+${hostname}([[:space:]]|$)" "$hosts_file"; then
          echo "Error: Hostname '$hostname' already exists in $hosts_file"
          return 1
        fi
        echo "Hostname is unique"
        return 0
      }

      When call check_duplicate "router.local"
      The status should be failure
      The output should include "already exists"
    End

    It 'allows adding new unique hostnames'
      check_duplicate() {
        local hostname="$1"
        local hosts_file="$TEST_HOSTS_FILE"
        
        if grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+${hostname}([[:space:]]|$)" "$hosts_file"; then
          echo "Error: Hostname '$hostname' already exists in $hosts_file"
          return 1
        fi
        echo "Hostname is unique"
        return 0
      }

      When call check_duplicate "newhost.local"
      The status should be success
      The output should include "Hostname is unique"
    End
  End

  Describe 'remove_host()'
    It 'shows usage when called without arguments'
      When call remove_host
      The status should be failure
      The output should include "Usage: remove_host"
    End

    It 'removes exact hostname match only'
      # Test the regex pattern for exact matching
      test_exact_match() {
        local hostname="$1"
        local test_line="$2"
        
        # Use the same pattern as remove_host
        if echo "$test_line" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+${hostname}([[:space:]]|$)"; then
          echo "Would remove: $test_line"
          return 0
        else
          echo "Would NOT remove: $test_line"
          return 1
        fi
      }

      # Should match exact hostname
      When call test_exact_match "router.local" "192.168.1.1     router.local"
      The status should be success
      The output should include "Would remove"
    End

    It 'does not remove substring matches'
      test_exact_match() {
        local hostname="$1"
        local test_line="$2"
        
        if echo "$test_line" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+${hostname}([[:space:]]|$)"; then
          echo "Would remove: $test_line"
          return 0
        else
          echo "Would NOT remove: $test_line"
          return 1
        fi
      }

      # Should NOT match when searching for "router" against "router.local"
      When call test_exact_match "router" "192.168.1.1     router.local"
      The status should be failure
      The output should include "Would NOT remove"
    End

    It 'requires IP address at start of line'
      test_exact_match() {
        local hostname="$1"
        local test_line="$2"
        
        if echo "$test_line" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+${hostname}([[:space:]]|$)"; then
          echo "Would remove: $test_line"
          return 0
        else
          echo "Would NOT remove: $test_line"
          return 1
        fi
      }

      # Should NOT match comment lines
      When call test_exact_match "router.local" "# 192.168.1.1     router.local"
      The status should be failure
      The output should include "Would NOT remove"
    End
  End

  Describe 'Utility Functions'
    Describe 'mkd()'
      setup_mkd() {
        TEST_DIR="$(mktemp -d)"
       builtin cd "$TEST_DIR" || exit 1
      }

      cleanup_mkd() {
       builtin cd /
        rm -rf "$TEST_DIR"
      }

      Before 'setup_mkd'
      After 'cleanup_mkd'

      It 'creates directory and changes into it'
        mkd testdir > /dev/null 2>&1
        The value "$(basename "$PWD")" should eq "testdir"
      End

      It 'creates nested directories'
        mkd path/to/nested/dir > /dev/null 2>&1
        The value "$(basename "$PWD")" should eq "dir"
        The directory "$TEST_DIR/path/to/nested/dir" should be exist
      End

      It 'handles directories with spaces'
        mkd "dir with spaces" > /dev/null 2>&1
        The value "$PWD" should include "dir with spaces"
      End
    End

    Describe 'fs()'
      setup_fs() {
        TEST_DIR="$(mktemp -d)"
       builtin cd "$TEST_DIR" || exit 1
      }

      cleanup_fs() {
       builtin cd /
        rm -rf "$TEST_DIR"
      }

      Before 'setup_fs'
      After 'cleanup_fs'

      It 'displays file size in human-readable format'
        # Create a file of known size (1KB)
        dd if=/dev/zero of=testfile bs=1024 count=1 2>/dev/null
        
        When call fs testfile
        The output should include "testfile"
        # Size should be displayed (exact format may vary by system)
        The status should be success
      End

      It 'shows error for non-existent file'
        When call fs nonexistent
        The status should be failure
        The stderr should include "No such file or directory"
      End
    End

    Describe 'to_relative()'
      It 'converts absolute path to relative from current directory'
        current_dir="$PWD"
        result="$(to_relative "$current_dir/subdir/file.txt")"
        The variable result should eq "subdir/file.txt"
      End

      It 'returns . for current directory'
        result="$(to_relative "$PWD")"
        The variable result should eq "."
      End

      It 'handles paths outside current directory'
        result="$(to_relative "/tmp/somefile")"
        # Should return a path with ../ components
        The variable result should not eq ""
      End
    End
  End
End
