# shellcheck shell=zsh
# ShellSpec tests for backup/restore system functions

Describe 'Backup and Restore System'
  Include zsh-setup-scripts/system/functions.zsh

  setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
   builtin cd "$TEST_DIR" || exit 1
  }

  cleanup() {
    # Clean up test directory
   builtin cd /
    rm -rf "$TEST_DIR"
  }

  Before 'setup'
  After 'cleanup'

  Describe 'new_bak()'
    It 'creates backup with .bak0 suffix for first backup'
      echo "original content" > testfile.txt
      When call new_bak testfile.txt
      The status should be success
      The output should include "Created new backup"
      The file .backups/testfile.txt.bak0 should be exist
      The contents of file .backups/testfile.txt.bak0 should eq "original content"
    End

    It 'creates incremental backups with increasing numbers'
      # Create three versions and back them up
      create_backups() {
        echo "version 1" > testfile.txt
        new_bak testfile.txt
        
        echo "version 2" > testfile.txt
        new_bak testfile.txt
        
        echo "version 3" > testfile.txt
        new_bak testfile.txt
      }
      
      When call create_backups
      The status should be success
      The output should include "Created new backup"
      
      # Should have .bak0, .bak1, .bak2
      The file .backups/testfile.txt.bak0 should be exist
      The file .backups/testfile.txt.bak1 should be exist
      The file .backups/testfile.txt.bak2 should be exist
      The contents of file .backups/testfile.txt.bak0 should eq "version 1"
      The contents of file .backups/testfile.txt.bak1 should eq "version 2"
      The contents of file .backups/testfile.txt.bak2 should eq "version 3"
    End

    It 'handles files with spaces in names'
      echo "content" > "file with spaces.txt"
      When call new_bak "file with spaces.txt"
      The status should be success
      The output should include "Created new backup"
      The file ".backups/file with spaces.txt.bak0" should be exist
    End

    It 'backs up directories recursively'
      mkdir -p testdir/subdir
      echo "file1" > testdir/file1.txt
      echo "file2" > testdir/subdir/file2.txt
      
      When call new_bak testdir
      The status should be success
      The output should include "Created new backup"
      The directory .backups/testdir.bak0 should be exist
      The file .backups/testdir.bak0/file1.txt should be exist
      The file .backups/testdir.bak0/subdir/file2.txt should be exist
    End

    It 'fails gracefully when target does not exist'
      When call new_bak nonexistent.txt
      The status should be failure
      The output should include "Error: Failed to copy"
      The stderr should include "No such file or directory"
    End

    It 'shows usage when called without arguments'
      When call new_bak
      The status should be failure
      The output should include "Usage: new_bak"
    End
    
    It 'creates backup of file in nested folder'
      mkdir -p nested/folder
      echo "nested content" > nested/folder/file.txt
      
      When call new_bak nested/folder/file.txt
      The status should be success
      The output should include "Created new backup"
      The file nested/folder/.backups/file.txt.bak0 should be exist
      The contents of file nested/folder/.backups/file.txt.bak0 should eq "nested content"
    End
  End

  Describe 'restore_bak()'
    It 'restores file from latest backup'
      setup_and_restore() {
        echo "original" > testfile.txt
        new_bak testfile.txt
        
        echo "modified" > testfile.txt
        new_bak testfile.txt
        
        echo "current" > testfile.txt
        
        restore_bak testfile.txt
      }
      
      When call setup_and_restore
      The status should be success
      The output should include "Using latest backup"
      The output should include ".backups/testfile.txt.bak1"
      The contents of file testfile.txt should eq "modified"
    End

    It 'restores from specific backup version'
      setup_and_restore_specific() {
        echo "version 1" > testfile.txt
        new_bak testfile.txt
        
        echo "version 2" > testfile.txt
        new_bak testfile.txt
        
        echo "current" > testfile.txt
        
        restore_bak .backups/testfile.txt.bak0
      }
      
      When call setup_and_restore_specific
      The status should be success
      The output should include "Restored 'testfile.txt' from '.backups/testfile.txt.bak0'"
      The contents of file testfile.txt should eq "version 1"
    End

    It 'creates safety backup before restoring'
      echo "original" > testfile.txt
      new_bak testfile.txt > /dev/null
      
      echo "current version" > testfile.txt
      restore_bak testfile.txt > /dev/null
      
      # Should have created a backup of "current version" before restoring
      The file .backups/testfile.txt.bak1 should be exist
      The contents of file .backups/testfile.txt.bak1 should eq "current version"
    End

    It 'restores directories'
      mkdir -p testdir
      echo "file1" > testdir/file1.txt
      new_bak testdir > /dev/null
      
      echo "modified" > testdir/file1.txt
      echo "new file" > testdir/file2.txt
      
      When call restore_bak testdir
      The status should be success
      The output should include "Using latest backup"
      The output should include "Restored 'testdir'"
      The contents of file testdir/file1.txt should eq "file1"
      The file testdir/file2.txt should not be exist
    End

    It 'handles restoring when original does not exist'
      echo "content" > testfile.txt
      new_bak testfile.txt > /dev/null
      rm testfile.txt
      
      When call restore_bak testfile.txt
      The status should be success
      The output should include "Warning: The original item"
      The file testfile.txt should be exist
    End

    It 'fails when no backup exists'
      When call restore_bak nonexistent.txt
      The status should be failure
      The output should include "No .backups folder found"
    End

    It 'shows usage when called without arguments'
      When call restore_bak
      The status should be failure
      The output should include "Usage: restore_bak"
    End
    
    It 'restores using just backup filename'
      echo "original" > testfile.txt
      new_bak testfile.txt > /dev/null
      echo "modified" > testfile.txt
      
      When call restore_bak testfile.txt.bak0
      The status should be success
      The output should include "Restored 'testfile.txt' from './.backups/testfile.txt.bak0'"
      The contents of file testfile.txt should eq "original"
    End
    
    It 'restores from inside .backups directory'
      echo "original" > testfile.txt
      new_bak testfile.txt > /dev/null
      echo "modified" > testfile.txt
      
     builtin cd .backups
      When call restore_bak testfile.txt.bak0
      The status should be success
      The output should include "Restored '../testfile.txt' from './testfile.txt.bak0'"
    End
  End

  Describe 'clean_bak()'
    It 'removes .backups directory in current directory'
      mkdir -p .backups
      touch .backups/file.txt.bak0
      
      When call clean_bak
      The status should be success
      The output should include "Removing"
      The directory .backups should not be exist
    End

    It 'removes .backups in specified directory'
      mkdir -p testdir/.backups
      touch testdir/.backups/file.txt.bak0
      
      When call clean_bak testdir
      The status should be success
      The output should include "Removing 'testdir/.backups'"
      The directory testdir/.backups should not be exist
    End

    It 'removes .backups recursively with -r flag'
      mkdir -p .backups dir1/.backups dir2/subdir/.backups
      touch .backups/file1.bak0
      touch dir1/.backups/file2.bak0
      touch dir2/subdir/.backups/file3.bak0
      
      When call clean_bak -r .
      The status should be success
      The output should include "Removing './.backups'"
      The directory .backups should not be exist
      The directory dir1/.backups should not be exist
      The directory dir2/subdir/.backups should not be exist
    End

    It 'shows help with -h flag'
      When call clean_bak -h
      The status should be success
      The output should include "Usage: clean_bak"
      The output should include "Options:"
    End

    It 'shows help with --help flag'
      When call clean_bak --help
      The status should be success
      The output should include "Usage: clean_bak"
    End

    It 'handles non-existent .backups gracefully'
      When call clean_bak
      The status should be success
      The output should include "No .backups found"
    End

    It 'fails when target is not a directory'
      touch notadir
      When call clean_bak notadir
      The status should be failure
      The output should include "not a directory"
    End
    
    It 'recursively removes .backups in specified directory'
      mkdir -p testdir/.backups testdir/sub/.backups testdir/sub/inner/.backups
      touch testdir/.backups/file.bak0
      touch testdir/sub/.backups/file.bak0
      touch testdir/sub/inner/.backups/file.bak0
      
      # Also create a .backups outside that should NOT be removed
      mkdir -p other/.backups
      touch other/.backups/file.bak0
      
      When call clean_bak -r testdir
      The status should be success
      The output should include "Removing 'testdir/.backups'"
      The directory testdir/.backups should not be exist
      The directory testdir/sub/.backups should not be exist
      The directory testdir/sub/inner/.backups should not be exist
      # other/.backups should still exist
      The directory other/.backups should be exist
    End
  End

  Describe 'Helper Functions'
    Describe '_sanitize_backup_path()'
      It 'removes ANSI escape codes'
        result="$(_sanitize_backup_path $'\033[31mred\033[0m')"
        The variable result should eq "red"
      End

      It 'removes newlines'
        result="$(_sanitize_backup_path "line1"$'\n'"line2")"
        The variable result should eq "line1line2"
      End
    End

    Describe '_parse_backup_path()'
      It 'extracts original path from backup path'
        mkdir -p dir/.backups
        touch dir/.backups/file.txt.bak0
       builtin cd dir/.backups || exit 1
        
        result="$(_parse_backup_path "$PWD/file.txt.bak0")"
        expected="$(cd .. && pwd)/file.txt"
        The variable result should eq "$expected"
      End
    End
  End
End
