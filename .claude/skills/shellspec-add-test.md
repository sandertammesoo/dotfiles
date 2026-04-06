# ShellSpec Add Test

Guide the user through writing a new ShellSpec test for the dotfiles project.

## When to use

User wants to add tests for a new function, extend existing test coverage, or verify a bug fix with a regression test.

## Key facts

- Framework: ShellSpec 0.28.1
- Config: `.shellspec` at repo root
- Run all tests: `shellspec`
- Run one file: `shellspec spec/logging_helpers/utilities_spec.sh`
- Total: 285 tests across 11 spec files

## Which suite does the new test belong to?

| Suite | What goes here |
|-------|---------------|
| `spec/logging_helpers/` | Tests for functions in `helpers_logging.zsh` |
| `spec/system_functions/` | Tests for `system/functions.zsh` (backup, hosts, utilities) |

If neither fits, create a new suite directory.

## Test file structure

```sh
#shellcheck shell=sh

# ============================================================================
# [Brief description of what's being tested]
# ============================================================================

Describe '[helpers_file.zsh - Section Name]'
  Include "$SHELLSPEC_SPECDIR/spec_helper.sh"

  Describe '[function_name]'
    BeforeEach 'setup_test_environment'
    AfterEach 'cleanup_test_environment'

    Context 'description of scenario'
      BeforeEach 'source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"'

      It 'should do the expected thing'
        When call function_name "arg"
        The status should be success
        The output should include "expected text"
      End

      It 'should handle edge case'
        When call function_name ""
        The status should be failure
      End
    End
  End
End
```

## Available test helpers (`spec/spec_helper.sh`)

- `setup_test_environment` — resets `LOG_LEVEL=INFO`, `LOG_FORMAT=standard`, `LOG_COLOR=auto`, `LOG_ENABLED=false`, unsets guards
- `cleanup_test_environment` — unsets test-specific variables
- `source_with_loglevel "DEBUG"` — sources `helpers_logging.zsh` with a specific log level
- `CALLER_INFO_PATH_DEPTH=3` — constant for path truncation depth

## Available custom matchers (`spec/support/custom_matchers.sh`)

Check what's in `spec/support/custom_matchers.sh` for project-specific matchers.

## Common ShellSpec assertions

```sh
The status should be success          # exit code 0
The status should be failure          # exit code non-0
The output should include "text"      # stdout contains text
The output should equal "exact"       # stdout matches exactly
The variable VAR should equal "val"   # variable value
The variable VAR should be undefined  # variable not set
The file "path" should be exist       # file exists
```

## Testing pattern for logging functions

Each logging test typically:
1. Calls `setup_test_environment` in `BeforeEach`
2. Sources `helpers_logging.zsh` in a nested `BeforeEach` (so log level is set first)
3. Calls the function under test
4. Asserts on output/status/variable state

Example from `spec/logging_helpers/utilities_spec.sh`:
```sh
BeforeEach 'setup_test_environment'
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
```

## After writing

Run the specific file to verify:
```bash
shellspec spec/[suite]/[new_file]_spec.sh
```

Then run the full suite to check nothing broke:
```bash
shellspec
```
