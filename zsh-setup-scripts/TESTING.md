# Testing Guide

This document explains how to run tests for the zsh-setup-scripts.

## Test Framework

Tests are written using [ShellSpec](https://shellspec.info/), a BDD-style testing framework for shell scripts.

## Installation

### Install ShellSpec

```bash
# Using Homebrew (recommended for macOS)
brew install shellspec

# Or using the official installer
curl -fsSL https://git.io/shellspec | sh

# Or manually
git clone https://github.com/shellspec/shellspec.git ~/.shellspec
export PATH="$HOME/.shellspec/bin:$PATH"
```

### Verify Installation

```bash
shellspec --version
```

## Running Tests

### Run All Tests

```bash
# From the dotfiles root directory
shellspec

# Or specify the spec directory
shellspec spec/
```

### Run Specific Test Files

```bash
# Run only backup/restore tests
shellspec spec/system_functions/backup_restore_spec.sh

# Run host management tests
shellspec spec/system_functions/host_management_spec.sh

# Run utility function tests
shellspec spec/system_functions/utilities_spec.sh
```

### Run Tests with Coverage

```bash
# Generate coverage report
shellspec --kcov

# View coverage in browser
open coverage/index.html
```

### Run Tests in Different Modes

```bash
# Verbose output
shellspec --format documentation

# Quick output
shellspec --format progress

# Fail fast (stop on first failure)
shellspec --fail-fast

# Run only failed tests from last run
shellspec --next-failure
```

## Test Structure

### Directory Layout

```
spec/
├── spec_helper.sh              # Global test configuration
├── support/
│   └── custom_matchers.sh      # Custom test matchers
├── logging_helpers/            # Tests for helpers_logging.zsh
│   ├── configuration_spec.sh
│   ├── formatting_spec.sh
│   ├── initialization_spec.sh
│   ├── log_functions_spec.sh
│   ├── path_caller_spec.sh
│   ├── state_management_spec.sh
│   └── utilities_spec.sh
└── system_functions/           # Tests for zsh-setup-scripts
    ├── backup_restore_spec.sh
    ├── host_management_spec.sh
    └── utilities_spec.sh
```

### Test File Anatomy

```bash
# shellcheck shell=zsh
# ShellSpec tests for feature X

Describe 'Feature Name'
  Include path/to/script.zsh

  setup() {
    # Runs before each test
    TEST_DIR="$(mktemp -d)"
  }

  cleanup() {
    # Runs after each test
    rm -rf "$TEST_DIR"
  }

  Before 'setup'
  After 'cleanup'

  Describe 'function_name()'
    It 'does something specific'
      When call function_name arg1 arg2
      The status should be success
      The output should include "expected text"
    End

    It 'handles error cases'
      When call function_name invalid_arg
      The status should be failure
      The error should include "error message"
    End
  End
End
```

## Test Coverage

### Current Test Coverage

**Backup & Restore System** (`backup_restore_spec.sh`):
- ✅ `new_bak()` - 6 test cases
- ✅ `restore_bak()` - 7 test cases
- ✅ `clean_bak()` - 6 test cases
- ✅ Helper functions - 2 test cases

**Host Management** (`host_management_spec.sh`):
- ✅ `add_host()` - 5 test cases
- ✅ `remove_host()` - 4 test cases
- ✅ Utility functions - 6 test cases

**Utilities** (`utilities_spec.sh`):
- ✅ `extract` - 8 test cases
- ✅ `c` (project navigation) - 5 test cases
- ✅ `gf` (git fetch) - 3 test cases
- ✅ Other utilities - 4 test cases

**Total**: 45+ test cases

### Coverage Goals

Current focus is on:
- Critical functions (backups, host management)
- Input validation and error handling
- Edge cases (spaces in filenames, missing files, etc.)

Future coverage should include:
- Git aliases and functions
- Tool integration scripts
- Environment setup scripts
- Completion scripts

## Writing Tests

### Best Practices

1. **Use Descriptive Names**: Test names should clearly state what they're testing
   ```bash
   It 'creates backup with .bak0 suffix for first backup'
   It 'handles files with spaces in names'
   ```

2. **Test One Thing**: Each test should verify one specific behavior
   ```bash
   # Good: focused test
   It 'shows error for non-existent file'
     When call extract nonexistent.tar.gz
     The status should be failure
     The output should include "does not exist"
   End

   # Bad: testing multiple things
   It 'works correctly'
     # Tests creation, listing, deletion all in one
   End
   ```

3. **Use Setup/Cleanup**: Keep tests isolated
   ```bash
   setup() {
     TEST_DIR="$(mktemp -d)"
     cd "$TEST_DIR"
   }

   cleanup() {
     cd /
     rm -rf "$TEST_DIR"
   }

   Before 'setup'
   After 'cleanup'
   ```

4. **Test Error Cases**: Don't just test the happy path
   ```bash
   It 'fails gracefully when target does not exist'
   It 'shows usage when called without arguments'
   It 'validates IP address format'
   ```

5. **Use Meaningful Assertions**:
   ```bash
   # Specific
   The output should include "Created new backup"
   The file .backups/test.txt.bak0 should exist

   # Less helpful
   The status should be success
   ```

### Common Matchers

```bash
# Status
The status should be success
The status should be failure

# Output
The output should include "text"
The output should eq "exact match"
The output should match pattern /regex/
The line 1 of output should include "first line"

# Files
The file path/to/file should exist
The file path/to/file should not exist
The directory path/to/dir should exist
The contents of file path should eq "content"

# Variables
The variable VAR should eq "value"
The variable VAR should be defined
```

### Mocking

When testing functions that call external commands:

```bash
It 'calls external command'
  # Mock the command
  open() { echo "Would open: $*"; }

  When call o testfile.txt
  The output should include "Would open: testfile.txt"
End
```

### Skipping Tests

Skip tests conditionally:

```bash
It 'extracts .tar.gz files'
  Skip if "tar not available" test -z "$(command -v tar)"
  
  # Test code
End
```

## Debugging Tests

### Run Single Test

```bash
# Run only tests matching a pattern
shellspec --example 'creates backup with .bak0 suffix'
```

### Verbose Output

```bash
# Show all output including stderr
shellspec --format documentation

# Show execution trace
shellspec --trace
```

### Interactive Debugging

Add `Debug` statements in tests:

```bash
It 'does something'
  Debug "TEST_DIR=$TEST_DIR"
  When call some_function
  Debug "Output was: $output"
  The status should be success
End
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install ShellSpec
        run: brew install shellspec
      - name: Run tests
        run: shellspec
```

## Troubleshooting

### Tests Failing Locally

1. **Check ShellSpec version**: `shellspec --version` (should be 0.28.1+)
2. **Ensure clean environment**: Tests create temporary directories
3. **Check file permissions**: Some tests require write access
4. **Review test output**: Use `--format documentation` for details

### Tests Pass Locally but Fail in CI

1. **Different shell versions**: CI may use different zsh version
2. **Missing dependencies**: Ensure all tools are installed
3. **Path differences**: Use absolute paths where possible
4. **Timing issues**: Add proper cleanup/setup

### Common Issues

**Issue**: `command not found: shellspec`
**Solution**: Install ShellSpec or add to PATH

**Issue**: Tests leave temp files
**Solution**: Ensure `After 'cleanup'` is called

**Issue**: Tests interfere with each other
**Solution**: Use unique temp directories per test

**Issue**: Mocked commands don't work
**Solution**: Define mocks as functions, not aliases

## Contributing Tests

When adding new functionality:

1. Write tests first (TDD approach)
2. Include both positive and negative cases
3. Test edge cases (empty input, spaces, special chars)
4. Add documentation in test description
5. Ensure tests are isolated (no dependencies between tests)

Example contribution:

```bash
Describe 'new_feature()'
  It 'works with normal input'
    # Test happy path
  End

  It 'handles edge case X'
    # Test edge case
  End

  It 'shows error for invalid input'
    # Test error handling
  End

  It 'shows usage when called incorrectly'
    # Test usage message
  End
End
```

## Resources

- [ShellSpec Documentation](https://github.com/shellspec/shellspec)
- [ShellSpec Examples](https://github.com/shellspec/shellspec-examples)
- [BDD Testing Guide](https://shellspec.info/)

## See Also

- `spec/spec_helper.sh` - Global test configuration
- `spec/support/custom_matchers.sh` - Custom test matchers
- `.shellcheckrc` - Linting configuration
