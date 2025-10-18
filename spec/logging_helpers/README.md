# Logging Helpers Test Suite

This directory contains the modular test suite for `helpers_logging.zsh`, split into logical functional areas for better maintainability and organization.

## Directory Structure

```
spec/logging_helpers/
├── README.md                      # This file
├── initialization_spec.sh         # Framework loading and initialization tests
├── configuration_spec.sh          # Log level and configuration tests
├── state_management_spec.sh       # Debug state and logging control tests
├── formatting_spec.sh             # Color codes and message formatting tests
├── path_caller_spec.sh            # Path conversion and caller info tests
├── log_functions_spec.sh          # Core logging functions and streams tests
└── utilities_spec.sh              # Utility helper functions tests
```

## Test Files

### 1. initialization_spec.sh (~190 lines, ~50 tests)
Tests framework loading and initialization behavior:
- Framework loading guard variables (`HELPERS_LOGGING_LOADED`)
- Default variable states (`LOG_ENABLED`, `LOG_LEVEL`, `LOG_FORMAT`, `LOG_COLOR`)
- Custom variable preservation during sourcing
- Invalid `LOG_LEVEL` fallback handling
- Double-loading protection
- Function availability (all 35+ functions parameterized)

**Key Tests:**
- Variable defaults (`LOG_ENABLED=false`, `LOG_LEVEL=INFO`)
- Double-source protection
- Invalid level fallback to INFO

### 2. configuration_spec.sh (~240 lines, ~40 tests)
Tests log level configuration and management:
- `_set_log_level`: Internal level setter (quiet)
- `set_log_level`: User-facing level setter with debug output
- `print_log_level`: Current level display
- `is_debug_enabled`: Debug state checker

**Key Tests:**
- Valid/invalid log level handling
- Debug output when `LOG_ENABLED=true` and changing to lower levels
- No debug output when changing to higher levels or `LOG_ENABLED=false`
- Caller info in debug output (detailed format)

### 3. state_management_spec.sh (~185 lines, ~20 tests)
Tests debug state control and message filtering:
- `_enable_debug`, `_disable_debug`, `_toggle_debug`: Internal state functions
- `enable_debug`, `disable_debug`, `toggle_debug`: User-facing state functions
- `should_log`: Log level filtering logic

**Key Tests:**
- State transitions (parametric: 5 tests)
- User output with caller info (7 tests)
- `should_log` filtering (24 parametric tests across 4 contexts)

### 4. formatting_spec.sh (~175 lines, ~22 tests)
Tests message formatting and color application:
- `color_text`: ANSI color code application
- `format_log_message`: Message formatting in 3 formats (minimal, standard, detailed)

**Key Tests:**
- Color application: never/always/auto (9 parameterized tests)
- Style application: bold, underline, combined (6 tests)
- Format types: minimal, standard, detailed with timestamps (7 tests)
- Caller info inclusion in detailed format

### 5. path_caller_spec.sh (~180 lines, ~15 tests)
Tests path conversion and call stack tracking:
- `to_relative`: Absolute-to-relative path conversion
- `get_caller_info`: Call stack information tracking

**Key Tests:**
- Path edge cases: same dir, parent, non-existent, spaces, special chars, symlinks, root
- Call stack tracking: direct calls, nested functions, deep stacks, sourced scripts
- Path truncation (last 3 directory levels)

### 6. log_functions_spec.sh (~350 lines, ~80 tests)
Tests core logging functions (largest file):
- `_log`: Internal logging with level-based filtering
- `log_trace`, `log_debug`, `log_info`, `log_warn`, `log_error`, `log_fatal`: Level-specific functions
- `log_success`, `log_failure`: Specialized logging
- `always`: Bypass `LOG_ENABLED` check
- `log_stream`, `error_stream`: Stream processing

**Key Tests:**
- `_log` filtering (10 parameterized tests)
- Level-specific functions (6 functions × 3 test types = 18 base tests + variations)
- Format handling (minimal, standard, detailed)
- Caller info in detailed format
- Color code application
- Stream routing (stdout vs stderr)
- Success/failure symbols (✓/✗)
- Stream processing (multi-line input)

### 7. utilities_spec.sh (~110 lines, ~7 tests)
Tests utility helper functions:
- `try_source`: Safely source files
- `_export_n_log`: Export variables with validation
- `add_to`: Add paths to environment variables without duplicates

**Key Tests:**
- File existence handling
- Valid/invalid variable assignments
- Duplicate path prevention
- Empty variable initialization

## Running Tests

### Run All Tests
```bash
shellspec spec/logging_helpers/
```

### Run Individual Test Files
```bash
shellspec spec/logging_helpers/initialization_spec.sh
shellspec spec/logging_helpers/configuration_spec.sh
shellspec spec/logging_helpers/state_management_spec.sh
shellspec spec/logging_helpers/formatting_spec.sh
shellspec spec/logging_helpers/path_caller_spec.sh
shellspec spec/logging_helpers/log_functions_spec.sh
shellspec spec/logging_helpers/utilities_spec.sh
```

### Run Specific Test Groups
```bash
# Test only log level configuration
shellspec spec/logging_helpers/configuration_spec.sh

# Test only core logging functions
shellspec spec/logging_helpers/log_functions_spec.sh

# Test only path and caller tracking
shellspec spec/logging_helpers/path_caller_spec.sh
```

## Test Statistics

- **Total Tests**: 209 examples
- **Test Files**: 7 files
- **Average File Size**: ~185 lines
- **Runtime**: ~1.8 seconds
- **Success Rate**: 100% (0 failures)

## File Split Benefits

### 1. **Improved Navigation**
- Quickly locate tests for specific functionality
- Clear separation of concerns
- Logical grouping by feature area

### 2. **Faster Subset Testing**
- Run only relevant tests during development
- Example: `shellspec spec/logging_helpers/formatting_spec.sh` (22 tests, ~0.3s)
- vs. full suite: 209 tests, ~1.8s

### 3. **Better Git History**
- Smaller, focused diffs
- Easier code review
- Clear impact of changes

### 4. **CI/CD Parallelization**
- Run test files in parallel
- Reduce overall CI pipeline time
- Better resource utilization

### 5. **Maintainability**
- Easier to add new tests to relevant file
- Less scrolling through large files
- Clear file purpose in headers

## Test Helpers

All test files share common helpers from `spec/spec_helper.sh`:

### Setup/Teardown
- `setup_test_environment`: Standard pre-test setup
- `cleanup_test_environment`: Standard post-test cleanup

### Source Helpers
- `source_with_loglevel_trace`: Source with LOG_LEVEL=TRACE
- `source_with_loglevel_debug`: Source with LOG_LEVEL=DEBUG
- `source_with_loglevel_info`: Source with LOG_LEVEL=INFO

### Configuration Helpers
- `configure_minimal_logging`: Set minimal format, enabled, no color
- `configure_disabled_logging`: Set LOG_ENABLED=false
- `configure_logging_with_level`: Flexible configuration

### Script Generation Helpers
- `create_logging_script`: Generate test script with logging call
- `create_nested_function_script`: Generate nested function test script
- `create_nested_temp_script_for_logging`: Generate script in temp directory
- `create_stream_test_script`: Generate stream processing test script

### Utility Helpers
- `get_higher_log_level`: Get next higher log level
- `assert_function_exists`: Check function availability

## Parametric Testing

Several test groups use ShellSpec's `Parameters` block for DRY testing:

### Example: Debug State Functions (state_management_spec.sh)
```bash
Parameters
  "_enable_debug"  "false" "true"  "enable debug logging"
  "_disable_debug" "false" "false" "disable debug logging from default state"
  "_disable_debug" "true"  "false" "disable debug logging when already enabled"
  "_toggle_debug"  "false" "true"  "toggle debug logging from false to true"
  "_toggle_debug"  "true"  "false" "toggle debug logging from true to false"
End

It "should $4"
  export LOG_ENABLED="$2"
  When call "$1"
  The status should be success
  The variable LOG_ENABLED should equal "$3"
End
```

This approach:
- Reduces code duplication by 90%+
- Makes test cases explicit in parameter table
- Easier to add new test cases
- Clear test matrix visualization

## Migration from Monolithic File

This directory structure replaces the original `spec/logging_helpers_spec.sh` (1,356 lines):

**Before:**
- 1 file × 1,356 lines
- ~2 minutes to read entire file
- All tests run together

**After:**
- 7 files × 100-350 lines each
- ~30 seconds to understand one file
- Selective test execution

**Migration Process:**
1. Created `spec/logging_helpers/` directory
2. Split tests by functional area
3. Adjusted paths: `../helpers_logging.zsh` → `../helpers_logging.zsh` (no change needed)
4. Preserved all 209 tests unchanged
5. Validated all tests pass

## Path Structure

Test files use relative paths from `$SHELLSPEC_SPECDIR`:

```bash
# $SHELLSPEC_SPECDIR = /path/to/dotfiles/spec
source "$SHELLSPEC_SPECDIR/../helpers_logging.zsh"
```

This works because:
- `$SHELLSPEC_SPECDIR` = `/path/to/dotfiles/spec`
- `$SHELLSPEC_SPECDIR/..` = `/path/to/dotfiles`
- `$SHELLSPEC_SPECDIR/../helpers_logging.zsh` = `/path/to/dotfiles/helpers_logging.zsh`

## Contributing

When adding new tests:

1. **Identify the functional area** (initialization, configuration, formatting, etc.)
2. **Add tests to the appropriate file**
3. **Use parametric approach** if testing multiple similar cases
4. **Update this README** if adding new functional areas
5. **Run full suite** to ensure no regressions

## References

- **ShellSpec Documentation**: https://shellspec.info/
- **Logging Framework**: `helpers_logging.zsh` (root directory)
- **Test Helpers**: `spec/spec_helper.sh`
- **Original Monolithic File**: See git history for `spec/logging_helpers_spec.sh`
