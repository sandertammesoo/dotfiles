# ShellSpec Debugging and Troubleshooting Guide

**Based on Official ShellSpec Documentation**

## Overview
This document outlines debugging approaches for ShellSpec test failures, based on the official ShellSpec README and practical experience.

## Quick Debugging Commands

```bash
# Syntax check only
shellspec --syntax-check spec/file_spec.sh

# Show translated shell script
shellspec --translate spec/file_spec.sh

# Run with trace output
shellspec --xtrace spec/file_spec.sh

# Run only failures
shellspec --repair

# Run failure and abort on first
shellspec --next-failure

# Run specific line
shellspec spec/file_spec.sh:10

# Run specific example ID
shellspec spec/file_spec.sh:@1-5

# Dry run (no execution)
shellspec --dry-run

# Count examples
shellspec --count

# List examples
shellspec --list examples
```

## Troubleshooting Checklist

When tests fail, check:

1. ☐ **Syntax**: Run `--syntax-check`
2. ☐ **Translation**: Check `--translate` output
3. ☐ **Shell**: Is correct shell being used?
4. ☐ **Context**: Are functions/variables in the right scope?
5. ☐ **Paths**: Are paths correct for execution directory?
6. ☐ **Hooks**: Do hooks have stderr output?
7. ☐ **Blocks**: Are all blocks properly closed with `End`?
8. ☐ **Empty blocks**: Are there any empty AfterAll/After blocks?
9. ☐ **Mocking**: Is the right type of mock being used?
10. ☐ **Working directory**: Is `$SHELLSPEC_SPECDIR` being used correctly?

## Resources

- **Official Documentation**: https://github.com/shellspec/shellspec/blob/master/README.md
- **Examples Directory**: https://github.com/shellspec/shellspec/tree/master/examples/spec
- **Online Demo**: https://shellspec.info/demo
- **Official Website**: https://shellspec.info/
