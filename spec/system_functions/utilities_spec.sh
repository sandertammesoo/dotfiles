# shellcheck shell=zsh
# ShellSpec tests for utility functions

Describe 'Utility Functions'
  Describe 'extract function'
    Include zsh-setup-scripts/functions/extract

    setup() {
      TEST_DIR="$(mktemp -d)"
     builtin cd "$TEST_DIR" || exit 1
      
      # Create test content
      mkdir -p testcontent
      echo "file1" > testcontent/file1.txt
      echo "file2" > testcontent/file2.txt
    }

    cleanup() {
     builtin cd /
      rm -rf "$TEST_DIR"
    }

    Before 'setup'
    After 'cleanup'

    It 'shows error when called without arguments'
      When call extract
      The output should include "is not a valid file"
    End

    It 'shows error for non-existent file'
      When call extract nonexistent.tar.gz
      The output should include "is not a valid file"
    End

    It 'extracts .tar.gz files'
      Skip if "tar not available" test -z "$(command -v tar)"
      
      tar czf test.tar.gz testcontent/
      rm -rf testcontent
      
      When call extract test.tar.gz
      The stderr should be present  # tar produces verbose output
      The directory testcontent should be exist
      The file testcontent/file1.txt should be exist
    End

    It 'extracts .zip files'
      Skip if "zip not available" test -z "$(command -v zip)"
      
      zip -r test.zip testcontent/ > /dev/null
      rm -rf testcontent
      
      When call extract test.zip
      The stdout should be present  # unzip produces verbose output
      The directory testcontent should be exist
      The file testcontent/file1.txt should be exist
    End

    It 'extracts .tar.bz2 files'
      Skip if "tar not available" test -z "$(command -v tar)"
      
      tar cjf test.tar.bz2 testcontent/
      rm -rf testcontent
      
      When call extract test.tar.bz2
      The stderr should be present  # tar produces verbose output
      The directory testcontent should be exist
    End

    It 'extracts .gz files'
      Skip if "gzip not available" test -z "$(command -v gzip)"
      
      gzip -c testcontent/file1.txt > test.gz
      
      When call extract test.gz
      The file test should be exist
    End

    It 'handles files with spaces in names'
      Skip if "tar not available" test -z "$(command -v tar)"
      
      tar czf "archive with spaces.tar.gz" testcontent/
      rm -rf testcontent
      
      When call extract "archive with spaces.tar.gz"
      The stderr should be present  # tar produces verbose output
      The directory testcontent should be exist
    End

    It 'shows error for unsupported archive types'
      touch unsupported.xyz
      When call extract unsupported.xyz
      The output should include "cannot be extracted"
    End
  End

  Describe 'c function (project navigation)'
    Include zsh-setup-scripts/functions/c

    setup() {
      # Create mock projects directory
      export PROJECTS="$(mktemp -d)"
      mkdir -p "$PROJECTS/project1"
      mkdir -p "$PROJECTS/project2"
      mkdir -p "$PROJECTS/nested/project3"
    }

    cleanup() {
      rm -rf "$PROJECTS"
      unset PROJECTS
    }

    Before 'setup'
    After 'cleanup'

    It 'shows usage when called without arguments'
      When call c
      The status should be failure
      The output should include "Usage: c"
    End

    It 'changes to project directory'
      c project1 > /dev/null 2>&1
      The value "$(basename "$PWD")" should eq "project1"
    End

    It 'shows error when PROJECTS is not set'
      unset PROJECTS
      When call c someproject
      The status should be failure
      The error should include "no such file or directory"
      The error should include "someproject"
    End

    It 'shows error when project does not exist'
      When call c nonexistent
      The status should be failure
      The error should include "no such file or directory"
    End

    It 'handles project names with spaces'
      mkdir -p "$PROJECTS/project with spaces"
      c "project with spaces" > /dev/null 2>&1
      The value "$PWD" should include "project with spaces"
    End
  End

  Describe 'colormap function'
    Include zsh-setup-scripts/system/functions.zsh

    It 'displays color codes'
      When call colormap
      The status should be success
      # Output should contain ANSI escape sequences
      The output should not eq ""
    End

    It 'shows 256 colors when available'
      When call colormap
      The status should be success
      # Should show multiple lines of output
      The line 1 of output should not eq ""
      The line 2 of output should not eq ""
    End
  End

  Describe 'o function (open files)'
    Include zsh-setup-scripts/system/functions.zsh

    setup() {
      TEST_DIR="$(mktemp -d)"
     builtin cd "$TEST_DIR" || exit 1
      echo "content" > testfile.txt
    }

    cleanup() {
     builtin cd /
      rm -rf "$TEST_DIR"
    }

    Before 'setup'
    After 'cleanup'

    It 'opens current directory when called without arguments'
      Skip if "macOS open command not available" test "$(uname)" != "Darwin"
      # Mock the open command
      open() { echo "Would open: $*"; }
      
      When call o
      The output should include "Would open: ."
    End

    It 'opens specified file'
      Skip if "macOS open command not available" test "$(uname)" != "Darwin"
      # Mock the open command
      open() { echo "Would open: $*"; }
      
      When call o testfile.txt
      The output should include "Would open: testfile.txt"
    End

    It 'handles multiple files'
      Skip if "macOS open command not available" test "$(uname)" != "Darwin"
      # Mock the open command  
      open() { echo "Would open: $*"; }
      
      echo "content2" > testfile2.txt
      When call o testfile.txt testfile2.txt
      The output should include "testfile.txt"
      The output should include "testfile2.txt"
    End
  End

  Describe 'rmd function (remove directory andbuiltin cd to parent)'
    Include zsh-setup-scripts/system/functions.zsh

    setup() {
      TEST_DIR="$(mktemp -d)"
      builtin cd "$TEST_DIR" || exit 1
      mkdir -p testdir/subdir
      builtin cd testdir/subdir || exit 1
    }

    cleanup() {
     builtin cd /
      rm -rf "$TEST_DIR"
    }

    Before 'setup'
    After 'cleanup'

    It 'removes current directory and moves to parent'
      # Create a directory to remove and cd into it
      mkdir -p removeme
      cd removeme
      current="$PWD"
      parent="$(dirname "$current")"
      
      # Remove current directory (rmd with no args removes current dir)
      When call rmd
      The status should be success
      # Should be in parent directory now
      The value "$PWD" should eq "$parent"
      # Original directory should not exist
      The directory "$current" should not be exist
    End

    It 'removes specified directory'
      mkdir -p "$TEST_DIR/removeme"
      When call rmd "$TEST_DIR/removeme"
      The directory "$TEST_DIR/removeme" should not be exist
    End

    It 'handles relative paths'
      mkdir -p ../removeme
      When call rmd ../removeme
      The directory "$TEST_DIR/removeme" should not be exist
    End
  End
End
