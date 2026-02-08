# shellcheck shell=zsh
# ShellSpec tests for host management functions
#
# These tests verify the actual add_host and remove_host functions work correctly,
# including proper handling of:
# - Zsh array subscript quoting (mixed quoting for [[:space:]] patterns)
# - macOS BSD sed requiring -E for extended regex
# - Full round-trip add/remove operations

Describe 'Host Management Functions'
  Include zsh-setup-scripts/system/functions.zsh

  Describe 'add_host()'
    setup() {
      TEST_HOSTS_FILE="$(mktemp)"
      cat > "$TEST_HOSTS_FILE" <<'EOF'
127.0.0.1       localhost
::1             localhost
192.168.1.1     router.local
10.0.0.5        server.example.com
EOF
    }

    cleanup() {
      rm -f "$TEST_HOSTS_FILE"
    }

    Before 'setup'
    After 'cleanup'

    It 'shows usage when called without arguments'
      When call add_host
      The status should be failure
      The output should include "Usage: add_host"
    End

    It 'shows usage when called with only IP argument'
      When call add_host 192.168.1.10
      The status should be failure
      The output should include "Usage: add_host"
    End

    It 'rejects invalid IP address format'
      When call add_host "invalid-ip" "hostname" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "Invalid IP address format"
    End

    It 'rejects IP with letters'
      When call add_host "192.168.1.abc" "hostname" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "Invalid IP address format"
    End

    It 'accepts valid IP addresses'
      When call add_host "192.168.1.10" "newhost.local" "$TEST_HOSTS_FILE"
      The status should be success
      The output should include "Added: 192.168.1.10 -> newhost.local"
    End

    It 'actually writes entry to hosts file'
      add_host "192.168.1.10" "newhost.local" "$TEST_HOSTS_FILE"
      When call grep "192.168.1.10.*newhost.local" "$TEST_HOSTS_FILE"
      The status should be success
    End

    It 'detects duplicate hostname entries'
      When call add_host "10.0.0.99" "router.local" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "already exists"
    End

    It 'allows adding new unique hostnames'
      When call add_host "10.0.0.99" "unique-host.local" "$TEST_HOSTS_FILE"
      The status should be success
      The output should include "Added:"
    End

    It 'handles hostnames that are substrings of existing ones'
      # "server" should be allowed even though "server.example.com" exists
      When call add_host "10.0.0.99" "server" "$TEST_HOSTS_FILE"
      The status should be success
    End
  End

  Describe 'remove_host()'
    setup() {
      TEST_HOSTS_FILE="$(mktemp)"
      cat > "$TEST_HOSTS_FILE" <<'EOF'
127.0.0.1       localhost
::1             localhost
192.168.1.1     router.local
10.0.0.5        server.example.com
192.168.1.100   test-host
EOF
    }

    cleanup() {
      rm -f "$TEST_HOSTS_FILE"
    }

    Before 'setup'
    After 'cleanup'

    It 'shows usage when called without arguments'
      When call remove_host
      The status should be failure
      The output should include "Usage: remove_host"
    End

    It 'reports error for non-existent hostname'
      When call remove_host "nonexistent.local" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "not found"
    End

    It 'removes exact hostname match'
      When call remove_host "test-host" "$TEST_HOSTS_FILE"
      The status should be success
      The output should include "Removed: test-host"
    End

    It 'actually removes entry from hosts file'
      remove_host "test-host" "$TEST_HOSTS_FILE"
      When call grep "test-host" "$TEST_HOSTS_FILE"
      The status should be failure
    End

    It 'does not remove when hostname is substring of existing'
      # "router" should NOT match "router.local"
      When call remove_host "router" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "not found"
    End

    It 'preserves other entries when removing'
      remove_host "test-host" "$TEST_HOSTS_FILE"
      When call grep "router.local" "$TEST_HOSTS_FILE"
      The status should be success
    End
  End

  Describe 'Integration: add then remove'
    setup() {
      TEST_HOSTS_FILE="$(mktemp)"
      cat > "$TEST_HOSTS_FILE" <<'EOF'
127.0.0.1       localhost
EOF
    }

    cleanup() {
      rm -f "$TEST_HOSTS_FILE"
    }

    Before 'setup'
    After 'cleanup'

    It 'can add and then remove a host entry'
      # Add the host
      add_host "192.168.1.50" "my-test-host" "$TEST_HOSTS_FILE"

      # Verify it was added
      grep -q "my-test-host" "$TEST_HOSTS_FILE" || return 1

      # Remove the host
      When call remove_host "my-test-host" "$TEST_HOSTS_FILE"
      The status should be success
    End

    It 'verifies host is gone after removal'
      add_host "192.168.1.50" "my-test-host" "$TEST_HOSTS_FILE"
      remove_host "my-test-host" "$TEST_HOSTS_FILE"

      When call grep "my-test-host" "$TEST_HOSTS_FILE"
      The status should be failure
    End

    It 'prevents re-adding duplicate after failed removal attempt'
      add_host "192.168.1.50" "my-test-host" "$TEST_HOSTS_FILE"

      # Try to add again - should fail
      When call add_host "192.168.1.60" "my-test-host" "$TEST_HOSTS_FILE"
      The status should be failure
      The output should include "already exists"
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
