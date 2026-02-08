# ShellSpec Official Reference

Based on the official README from https://github.com/shellspec/shellspec

## Table of Contents

- [Quick Start](#quick-start)
- [Basic DSL Syntax](#basic-dsl-syntax)
- [Specfile Structure](#specfile-structure)
- [Debugging and Testing](#debugging-and-testing)
- [Important Notes](#important-notes)

## Quick Start

### Installation and Initialization
```bash
# Initialize your project
shellspec --init

# This creates:
# .shellspec (project options file)
# spec/spec_helper.sh (helper file for specfiles)
```

### Basic Specfile Structure
```sh
#shellcheck shell=sh

Describe 'bc command'
  bc() { echo "$1 + $2" | command bc; }

  It 'performs addition'
    When call bc 2 3
    The output should eq 5
  End
End
```

## Basic DSL Syntax

### Example Groups

- `Describe`, `Context`, `ExampleGroup` - Block for grouping examples
- These are all aliases for the same thing
- Can be nested
- Can be tagged
```sh
Describe 'is example group'
  Describe 'is nestable'
    ...
  End

  Context 'is used to facilitate understanding'
    ...
  End
End
```

### Examples

- `It`, `Specify`, `Example` - Block for writing evaluations and expectations
- All three are aliases
- Can be tagged
```sh
It 'performs addition'
  When call add 2 3
  The output should eq 5
End
```

### Empty Examples

- `Todo` - One-liner empty example (treated as pending)
```sh
Todo 'will be used later when we write a test'

It 'is an empty example'
End
```

### Evaluation - `When`

Executes a shell function or command for verification. Only one evaluation per example.

#### `call` - Call without subshell
```sh
When call add 1 2  # call `add` shell function
```

#### `run` - Run within subshell
```sh
When run touch /tmp/foo  # run `touch` command
```

Special handlers for `run`:
- `command` - Runs an external command (respects shebang)
- `script` - Runs a shell script (ignores shebang, uses same shell)
- `source` - Sources a script using `.` command (ignores shebang)
```sh
When run command touch /tmp/foo
When run script my.sh
When run source my.sh
```

### Expectations - `The`

#### Basic Syntax
```sh
The output should equal 4
The output should not equal 5
```

#### Subjects

The target of verification:
- `output` (or `stdout`)
- `error` (or `stderr`)
- `status`
- `variable`
- `path`
```sh
The output should equal 4
The status should be success
The variable foo should equal "bar"
```

#### Modifiers

Concretize the target:
- `line` - Specific line of output
- `word` - Specific word
- `length` - Length of something
- `contents` - Contents of something
- `result` - Result of a user-defined function
```sh
The line 2 of output should equal 4
The word 1 of line 2 of output should equal 4
The first word of second line of output should equal 4
```

#### Matchers

The actual verification:
- String matchers
- Status matchers
- Variable matchers  
- Stat matchers
- And more...
```sh
The output should equal 4
The status should be success
The file "/tmp/foo" should exist
```

#### Language Chains

Improves readability (no functional effect): `a`, `an`, `as`, `the`
```sh
The first word of the second line of output should valid as a number
```

### Custom Assertions - `Assert`

For verifying side effects with user-defined functions:
```sh
still_alive() {
  ping -c1 "$1" >/dev/null
}

Describe "example.com"
  It "responses"
    Assert still_alive "example.com"
  End
End
```

## Specfile Structure

### Hooks

#### Example Hooks
```sh
Describe 'example hook'
  setup() { :; }
  cleanup() { :; }
  BeforeEach 'setup'    # Use Before in versions < 0.28.0
  AfterEach 'cleanup'   # Use After in versions < 0.28.0

  It 'is called before and after each example'
    ...
  End
End
```

**Important Notes:**
- `BeforeEach` and `AfterEach` are supported in version 0.28.0 and later
- Previous versions should use `Before` and `After` instead
- `AfterEach` is for cleanup, NOT for assertions!

#### Example Group Hooks
```sh
Describe 'example group hook'
  setup() { :; }
  cleanup() { :; }
  BeforeAll 'setup'
  AfterAll 'cleanup'

  It 'example 1'
    ...
  End

  It 'example 2'
    ...
  End
End
```

### Helpers

#### `Dump` - Debugging
```sh
When call echo hello world
Dump  # Shows stdout, stderr, and status
```

#### `Include` - Include a script
```sh
Describe 'lib.sh'
  Include lib.sh  # Loads the script

  Describe 'hello()'
    It 'says hello'
      When call hello ShellSpec
      The output should equal 'Hello ShellSpec!'
    End
  End
End
```

#### `Set` - Shell options
```sh
Describe 'Set helper'
  Set 'errexit:off' 'noglob:on'

  It 'sets shell options'
    When call foo
  End
End
```

#### `Path`, `File`, `Dir` - Path alias
```sh
Describe 'Path helper'
  Path hosts-file="/etc/hosts"

  It 'defines short alias'
    The path hosts-file should exist
  End
End
```

#### `Data` - Pass data as stdin
```sh
Describe 'Data helper'
  It 'provides data'
    Data
      #|item1 123
      #|item2 456
      #|item3 789
    End
    When call awk '{total+=$2} END{print total}'
    The output should eq 1368
  End
End
```

#### `Parameters` - Parameterized tests
```sh
Describe 'example'
  Parameters
    "#1" 1 2 3
    "#2" 1 2 3
  End

  Example "example $1"
    When call echo "$(($2 + $3))"
    The output should eq "$4"
  End
End
```

### Pending, Skip, and Focus

#### Pending
```sh
Pending "not implemented"

It 'will success when test fails'
  When call hello world
  The output should "Hello world"
End
```

#### Skip
```sh
Skip "not exists bc"

It 'is always skip'
  ...
End
```

##### Conditional Skip
```sh
not_exists_bc() { ! type bc >/dev/null 2>&1; }
Skip if "not exists bc" not_exists_bc

It 'performs addition'
  When call add 2 3
  The output should eq 5
End
```

#### Skip with 'x' prefix
```sh
xDescribe 'is skipped example group'
  ...
End

xIt 'is skipped example'
  ...
End
```

#### Focus with 'f' prefix
```sh
fDescribe 'is focused example group'
  ...
End

fIt 'is focused example'
  ...
End
```

Use with `shellspec --focus` to run only focused examples.

### Temporary vs Non-temporary Skip/Pending

**Temporary** (without message):
```sh
Pending
Skip
Todo
xIt 'example'
End
```

**Non-temporary** (with message):
```sh
Pending "reason"
Skip "reason"
Skip if "reason" condition
Todo "It will be implemented"
```

## Debugging and Testing

### Command Line Options
```bash
# Syntax check
shellspec --syntax-check

# Show translation
shellspec --translate

# Enable trace output
shellspec --xtrace

# Quick mode (run not-passed examples)
shellspec --quick

# Run failures only
shellspec --repair

# Run failure and abort on first
shellspec --next-failure

# Focus mode
shellspec --focus

# Run specific line
shellspec spec/file_spec.sh:10

# Run specific ID
shellspec spec/file_spec.sh:@1-5

# Dry run
shellspec --dry-run

# Count examples
shellspec --count

# List examples
shellspec --list examples
```

### Debugging Tools

#### %logger Directive
```sh
It 'debugs with logger'
  %logger "Debug message"
  When call foo
  The output should equal "bar"
End
```

Output goes to `--log-file` (default: `/dev/tty`).

#### Dump Helper
```sh
It 'dumps output'
  When call echo "test"
  Dump  # Shows stdout, stderr, status
  The output should equal "test"
End
```

## Important Notes

### Specfile Execution with `/bin/sh`

ShellSpec CLI runs specfiles with the shell running `shellspec`. Usually it is `/bin/sh` that is the shebang of `shellspec`. If you run `bash shellspec`, it will be bash. `Include` files from specfile will be executed in the same shell as well.

If you want to test with a specific shell, use the `-s` (`--shell`) option. You can specify the default shell in the `.shellspec` file.

**Note:** If you execute a **shell script file** (not a shell function) from within the specfile, its shebang will be respected. The `-s` (`--shell`) option has no effect in this case.

### Hook Pitfalls

**Problem**: Hooks may fail in subtle ways if there is output to stderr, even if the return code / exit code is `0`.

**Cause**: Commands like `git checkout` routinely write to stderr, even if there was no actual failure.

**Solution**: Redirect stderr in hooks:
```sh
BeforeEach 'setup'
setup() {
  git checkout branch 2>/dev/null
}
```

### Working Directory (Since 0.28.0)

**Important Change**: Since version 0.28.0, the working directory when running a specfile is the project root directory by default. Before 0.27.x, it was the current directory when the `shellspec` command was executed.

**Solution**: Use `$SHELLSPEC_SPECDIR` for spec directory relative paths:
```sh
Include "$SHELLSPEC_SPECDIR/../lib/script.sh"
```

Or use the `--execdir` option to change execution directory:
- `@project` - Where the `.shellspec` file is located (project root) [default]
- `@basedir` - Where the `.shellspec` or `.shellspec-basedir` file is located
- `@specfile` - Where the specfile is located

### About Executing Aliases

If you want to execute aliases, you need a workaround using `eval`:
```sh
alias alias-name='echo this is alias'
When call alias-name # alias-name: not found

# eval is required
When call eval alias-name

# When using embedded shell scripts
foo() { eval alias-name; }
When call foo
```

## Best Practices

1. **Use `BeforeEach`/`AfterEach`** instead of `Before`/`After` (for versions >= 0.28.0)
2. **Keep `AfterEach` for cleanup only**, not assertions
3. **Use `$SHELLSPEC_SPECDIR`** for relative paths to spec directory
4. **Redirect stderr in hooks** that might have benign stderr output
5. **Use `Dump` and `%logger`** for debugging
6. **Use `--translate`** to see what ShellSpec generates
7. **Use `--focus`** during development to run specific tests
8. **Tag your examples** for better organization and filtering

## Quick Reference

### File Naming
- Specfiles must end with `_spec.sh`
- Default location: `spec/` directory
- Pattern can be changed with `--pattern`

### Project Files
- `.shellspec` - Project options (required)
- `spec/spec_helper.sh` - Helper file loaded with `--require spec_helper`
- `.shellspec-local` - Local overrides (not in VCS)
- `.shellspec-basedir` - Specfile execution base directory marker

### Environment Variables

**Available in specfiles:**
- `$SHELLSPEC_SPECDIR` - Directory containing specfiles
- `$SHELLSPEC_PROJECT_ROOT` - Project root directory
- `$SHELLSPEC_VERSION` - ShellSpec version

**Available only in `spec_helper` precheck callback:**
- `$VERSION` - ShellSpec Version
- `$SHELL_TYPE` - Currently running shell type (e.g. `bash`)
- `$SHELL_VERSION` - Currently running shell version (e.g. `4.4.20(1)-release`)

**Note:** `$SHELL` (user login shell) is a system environment variable, unrelated to ShellSpec.

### Return Codes
- 0 - Success
- 101 - Failure (can be changed with `--failure-exit-code`)
- 102 - Fatal error (can be changed with `--error-exit-code`)

### Evaluation Types

| Type | Description | Subshell | Coverage | Shebang |
|------|-------------|----------|----------|---------|
| `call` | Call function/command | No | Yes | N/A |
| `run` | Run in subshell | Yes | No | Respected |
| `run command` | Run external command | Yes | No | Respected |
| `run script` | Run as shell script | Yes | Yes | Ignored |
| `run source` | Source with `.` command | Yes | Yes | Ignored |

### spec_helper Callbacks
```sh
# Filename: spec/spec_helper.sh

# Called once before loading specfiles (separate process)
spec_helper_precheck() {
  minimum_version "0.28.0"
  # Available: minimum_version, error, warn, info, abort, setenv, unsetenv
  # Variables: VERSION, SHELL_TYPE, SHELL_VERSION
}

# Called after loading internal functions (may be called multiple times)
spec_helper_loaded() {
  : # Rarely used - for shell-specific workarounds
}

# Called after core modules loaded (may be called multiple times)
spec_helper_configure() {
  import 'support/custom_matcher'
  before_each "global_hook"
  # Available: import, before_each, after_each, before_all, after_all
}
```

### Testing Single File Scripts

To test a single-file shell script, add this to your script:
```sh
#!/bin/sh

# Allow the script to be sourced for testing
${__SOURCED__:+return}

# Script continues normally...
```

Then in your specfile:
```sh
Describe 'my_script.sh'
  Include './my_script.sh'  # Defines __SOURCED__, script returns
  
  Describe 'my_function()'
    It 'works correctly'
      When call my_function
      The output should equal "expected"
    End
  End
End
End
```

### Intercepting (Advanced)

For testing single-file scripts that need function mocking during execution:

**In your script:**
```sh
#!/bin/sh
test || __() { :; }  # Define no-op __ function for production

my_function() {
  # ... code ...
}

__ intercept_point __  # Interception point

my_function  # Call the function
```

**In your specfile:**
```sh
Describe 'my_script.sh'
  Intercept intercept_point
  
  __intercept_point__() {
    # Mock or modify behavior here
    %preserve some_var  # Preserve variables from subshell
  }
  
  It 'runs with mocked behavior'
    When run source ./my_script.sh
    The output should equal "expected"
  End
End
```

## Resources

- Official Website: https://shellspec.info/
- GitHub: https://github.com/shellspec/shellspec
- Online Demo: https://shellspec.info/demo
- Examples: https://github.com/shellspec/shellspec/tree/master/examples/spec

## Key Differences from BATS

For those migrating from BATS:

1. **Structure**: ShellSpec uses `Describe`/`It` blocks (BDD style) vs BATS's `@test`
2. **Evaluation**: Explicit `When call/run` vs BATS's `run` command
3. **Assertions**: Readable English-like syntax (`The output should equal`) vs BATS's `[ ]` tests
4. **Coverage**: Built-in coverage support with kcov
5. **Hooks**: More granular hooks (BeforeEach, AfterEach, BeforeAll, AfterAll)
6. **Scoping**: Automatic scope management with blocks
7. **Shell Support**: Tests work across multiple shells (dash, bash, zsh, ksh, etc.)
8. **Execution**: Specfiles run by default in `/bin/sh`, configurable with `--shell`

---

**Document Version**: Based on ShellSpec official README  
**Last Updated**: October 2024  
**ShellSpec Version**: 0.28.0+