# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal macOS dotfiles with XDG Base Directory compliance, modular shell configuration, and comprehensive window management integration.

**Platform**: macOS (Darwin) - Intel and Apple Silicon support
**Repository**: https://github.com/sandertammesoo/dotfiles

## Architecture

### Topic-Centric Organization

Configuration is organized by tool/feature rather than file type. Each tool has its own directory with associated files.

### Key Architectural Patterns

1. **XDG Base Directory Compliance**: All configurations respect XDG specification
2. **Modular Loading**: Configuration files discovered and loaded by naming convention
3. **Separation of Concerns**: Installation, configuration, and runtime logic cleanly separated
4. **Safety-First**: Extensive error handling, input validation, and backup mechanisms
5. **Test-Driven**: Critical infrastructure has comprehensive test coverage (285 tests)

### Directory Structure

```
/Users/sander/projects/dotfiles/
├── bin/                          # Executable scripts (added to PATH)
│   └── git-*                     # 15 git utility commands
├── brewfiles/                    # Homebrew package definitions
│   └── Brewfile                  # Main package list with comments
├── spec/                         # ShellSpec test suite (285 tests)
│   ├── logging_helpers/          # 8 test files for logging framework
│   └── system_functions/         # Tests for backup/restore/hosts
├── xdg_config/                   # XDG configs (→ ~/.config)
│   ├── yabai/                    # Window manager (14 files)
│   ├── skhd/                     # Hotkey daemon
│   ├── sketchybar/               # Status bar
│   └── zsh/                      # Zsh core configuration
├── zsh-setup-scripts/            # Modular shell config (29 subdirs)
│   ├── homebrew/                 # Homebrew setup
│   ├── yabai/                    # Yabai bootstrap
│   ├── system/functions.zsh      # Backup/restore/host management
│   └── */                        # Per-tool configs
├── helpers_logging.zsh           # Logging framework (1014 lines)
├── helpers_misc.zsh              # Misc utilities (78 lines)
├── dotbot.conf.yaml              # DotBot symlink configuration
├── install-all                   # Master installation script
└── .shellspec                    # ShellSpec test configuration
```

## Common Commands

### Installation

```bash
# New machine setup
mkdir ~/projects
cd ~/projects
git clone https://github.com/sandertammesoo/dotfiles.git
cd dotfiles
./run-dotbot

# Full installation
./install-all

# Debug mode
./install-all --debug

# Skip specific steps
./install-all --skip-dotbot              # Skip DotBot symlink setup
./install-all --skip-updates             # Skip all updates (OSX + Homebrew)
./install-all --skip-osx-updates         # Skip only macOS software updates
./install-all --skip-app-installation    # Skip Homebrew/mas app installations
./install-all --skip-brew-upgrades       # Skip Homebrew package upgrades
./install-all --skip-services            # Skip service setup (yabai/skhd/sketchybar)

# Optional features
./install-all --setup-lazyman            # Setup Lazyman Neovim configuration

# Logging levels
./install-all --trace                    # Maximum detail logging
./install-all --verbose                  # Verbose logging
./install-all --debug                    # Debug logging
./install-all --quiet                    # Minimal logging (errors only)
./install-all --silent                   # No output

# Combine flags
./install-all --skip-dotbot --skip-services --debug
```

### Testing

```bash
# Run all tests (285 examples)
shellspec

# Run specific test suite
shellspec spec/logging_helpers/

# Run with coverage
shellspec --kcov

# Single test file
shellspec spec/logging_helpers/formatting_spec.sh
```

### Homebrew

```bash
# Install all packages
brew bundle --file=brewfiles/Brewfile

# Check status
brew bundle check --file=brewfiles/Brewfile

# List manually installed
brew leaves
```

### Yabai Window Manager

```bash
# Service control
yabai --start-service
yabai --restart-service

# Query state
yabai -m query --windows
yabai -m query --spaces

# Debug logs
tail -f /tmp/yabai_minimize_debug.log
```

### Shell Configuration

```bash
# Enable debug logging
enable_debug
set_log_level DEBUG

# Check log level
print_log_level

# Reload configuration
source ~/.zshenv
```

### Backup/Restore

```bash
# Create incremental backup
new_bak ~/.zshrc

# Restore from backup
restore_bak ~/.zshrc

# Clean backups
clean_bak           # Current dir
clean_bak -r .      # Recursive
```

## Installation System

### Master Script: `install-all`

Orchestrates complete system setup with configurability and security.

**Features**:
- **Conditional Execution Flags**:
  - `--skip-dotbot` / `-d` - Skip DotBot symlink setup
  - `--skip-updates` / `-u` - Skip all updates (OSX + Homebrew)
  - `--skip-osx-updates` / `-o` - Skip only macOS software updates
  - `--skip-app-installation` / `-i` - Skip Homebrew/mas app installations
  - `--skip-brew-upgrades` / `-b` - Skip Homebrew package upgrades
  - `--skip-services` / `-s` - Skip service setup (yabai/skhd/sketchybar)
  - `--setup-lazyman` / `-l` - Setup Lazyman Neovim configuration
- **Logging Level Control**: trace/verbose/debug/quiet/silent (`-T`/`-V`/`-D`/`-Q`/`-S`)
- **Security Features**:
  - Sudo privilege management with timeout and parent process checks
  - Installer whitelist validation
- **Error Handling**:
  - Cleanup handlers for graceful exit
  - Exit code tracking (returns 0 on success, 1 on failures)

**Security**:
- **Whitelist Validation**: Only approved `install.sh` scripts can execute
- **Sudo Keep-Alive**: Background process with 30-minute timeout (60 iterations × 30 seconds)
- **Parent Process Check**: Sudo keep-alive terminates if parent exits (prevents runaway processes)
- **Null-Terminated Find**: Uses `find -print0` for safe handling of paths with spaces

**Execution Flow**:
1. Parse options using `zparseopts`
2. Setup logging and boolean flags
3. Request sudo (with keep-alive)
4. Run DotBot (creates dirs and symlinks)
5. Discover and validate `install.sh` scripts against whitelist
6. Execute whitelisted installers
7. Setup services (yabai, skhd, sketchybar)
8. Display summary with exit code

### DotBot: `dotbot.conf.yaml`

Declarative symlink and directory management.

**Actions**:
1. Create XDG directories
2. Clean old dotfiles from home
3. Initialize git submodules
4. Create symlinks (xdg_config → ~/.config)
5. Migrate zsh history to XDG location
6. Special symlinks:
   - `~/.zshenv` → `~/.config/.zsh/.zshenv` (required for zsh)
   - `~/.config/.dotfiles` → repository root

### Bootstrap Scripts

Each tool has `bootstrap.sh` or `install.sh` in `zsh-setup-scripts/[tool]/`:
- `homebrew/install.sh` - Install/update Homebrew (whitelisted)
- `osx/install.sh` - macOS software updates (whitelisted)
- `lazyman/install.sh` - Lazyman Neovim setup (exists, commented out in whitelist)
- `yabai/bootstrap.sh` - Install yabai, configure sudoers, start service
- `skhd/bootstrap.sh` - Install hotkey daemon
- `sketchybar/bootstrap.sh` - Install status bar

**Whitelist**: Only `homebrew/install.sh` and `osx/install.sh` are currently whitelisted for automatic execution by `install-all`. The `lazyman/install.sh` installer exists but is commented out in the whitelist (can be enabled with `--setup-lazyman` flag). Other installers must be added to the whitelist before they will run.

## Shell Configuration Loading

### Entry Point: `~/.zshenv`

Loaded for ALL shells (login, interactive, scripts).

**Loading Sequence**:
1. Check if in test environment (skip if ShellSpec)
2. Source `helpers.zsh` (loads logging framework and utilities)
3. Set XDG Base Directory variables
4. Add directories to PATH and MANPATH
5. Source `zsh/fpath.zsh` for function paths

### Helper Functions: `helpers.zsh`

**Location**: `/Users/sander/projects/dotfiles/helpers.zsh`
**Purpose**: Central loader for helper function modules

**Contents**:
- Sources `helpers_logging.zsh` - Full logging framework (1014 lines, 285 tests)
- Sources `helpers_misc.zsh` - Miscellaneous utilities (78 lines)
  - `get_zsh_files()` - Discovers configuration files by category
  - Path manipulation utilities
  - File discovery functions

This file is sourced early in `.zshenv` to make logging and utility functions available for all subsequent configuration loading operations.

### Interactive Shells: `~/.zshrc`

**Loading Order**:
1. Source Homebrew environment first
2. Load `zsh/config.zsh` (core options)
3. Source `.localrc` if exists (private vars)
4. Discover and load by category:
   - `env.zsh` files (environment)
   - `other.zsh` files
   - `aliases.zsh` files
   - `functions.zsh` files
5. Initialize completion (`compinit`)
6. Load `completion.zsh` files
7. Source zoxide (must be after compinit)

### File Discovery Pattern

**Function**: `get_zsh_files()` in `helpers_misc.zsh`

**Categories**:
- `env`: Environment variables and initialization
- `alias`: Command aliases
- `func`: Shell functions
- `completion`: Tab completion setup
- `other`: Everything else

**Exclusions**:
- `homebrew/env.zsh` (loaded explicitly first)
- `zoxide/env.zsh` (loaded explicitly after compinit)
- `zsh/config.zsh` (loaded explicitly early)
- `zsh/fpath.zsh` (loaded from .zshenv)

## Logging Infrastructure

**File**: `helpers_logging.zsh` (1014 lines)
**Status**: Fully refactored with 285 passing tests
**Documentation**: `.claude/README.md`

### Features

- **7 Log Levels**: TRACE, VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL
- **3 Format Modes**: minimal, standard, detailed (with caller info)
- **Color Support**: auto/always/never with ANSI colors
- **Debug Toggle**: Runtime enable/disable
- **Caller Tracking**: Automatic call stack information
- **Stream Processing**: Pipe multi-line output through log levels
- **Sensitive Data Redaction**: Auto-redact passwords, tokens, keys

### Configuration

```bash
LOG_LEVEL="INFO"        # Minimum level to log
LOG_ENABLED="false"     # Debug mode toggle
LOG_FORMAT="detailed"   # Message format
LOG_COLOR="auto"        # Color output control
```

### Core Functions

**Log Levels**:
- `log_trace` - Trace execution flow
- `log_debug` / `log_verbose` - Debug information
- `log_info` - Informational messages
- `log_warn` - Warnings
- `log_error` - Errors
- `log_fatal` - Fatal errors
- `log_success` / `log_fail` - Operation results
- `log_skip` - Skip notifications (yellow, for operations intentionally skipped)
- `log_user` / `log_user2` - User-facing messages (always shown regardless of log level)

**State Management**:
- `enable_debug` / `disable_debug` / `toggle_debug`
- `set_log_level LEVEL`
- `print_log_level`
- `is_debug_enabled`

**Utilities**:
- `try_source FILE [LOGLEVEL]` - Safe file sourcing with error handling
- `export_n_log VAR VALUE` - Export and log (with redaction)
- `add_to VAR PATH` - Add to PATH-like variables without duplicates
- `output_stream` - Process command output through logging

### Usage Examples

```bash
# Basic logging
log_info "Starting installation"
log_error "Failed to install package"

# Enable debug mode
enable_debug
set_log_level DEBUG

# Safe file sourcing
try_source "$HOME/.localrc" info

# Export with logging (redacts sensitive values)
export_n_log PATH "/usr/local/bin:$PATH"
export_n_log API_KEY "secret123"  # Will be redacted

# Stream processing
brew install somepackage 2>&1 | output_stream
```

## Testing Infrastructure

### ShellSpec Configuration

**File**: `.shellspec`
**Framework**: ShellSpec 0.28.1
**Test Files**: 11 spec files
**Total Tests**: 285 examples, 0 failures

**Test Suites**:
1. **`spec/logging_helpers/`** (8 files):
   - `initialization_spec.sh` - Framework loading
   - `configuration_spec.sh` - Log level configuration
   - `state_management_spec.sh` - Debug state control
   - `formatting_spec.sh` - Message formatting and colors
   - `path_caller_spec.sh` - Path conversion and call tracking
   - `log_functions_spec.sh` - Core logging functions
   - `output_stream_spec.sh` - Stream processing
   - `utilities_spec.sh` - Utility helpers

2. **`spec/system_functions/`** (3 files):
   - `backup_restore_spec.sh` - Backup/restore system
   - `host_management_spec.sh` - /etc/hosts manipulation
   - `utilities_spec.sh` - General utilities

### Test Helpers

**File**: `spec/spec_helper.sh`

Provides test lifecycle management, environment setup, and assertion helpers.

## Yabai Window Management

### Overview

**Components**:
- **Yabai**: Tiling window manager
- **SKHD**: Hotkey daemon (keybindings)
- **SketchyBar**: Status bar
- **Borders**: Window border highlighting

### Configuration: `xdg_config/yabai/yabairc`

**Key Features**:
1. **Scripting Addition**: Sudo-enabled for advanced features
2. **Signal Handlers**: Event-driven window management
3. **Application Rules**: 38 apps with per-app behavior
4. **Window Stacking**: Automatic grouping logic
5. **Debug Logging**: Comprehensive minimize bug tracking

**Signals (Active)**:
- `window_focused` → Update SketchyBar + debug logging
- `window_minimized` / `window_deminimized` → Debug logging
- `application_front_switched` → Debug logging

**Signals (Disabled)**:
- `application_activated` → **DISABLED** - Root cause of minimize bug
- `window_created` → **DISABLED** - Root cause of minimize bug cascade

> **Note**: The `application_activated` and `window_created` signals are commented out in yabairc because the window queries in these event handlers disturb minimized windows across all applications. See `.claude/YABAI_MINIMIZE_BUG/` for full investigation.

**Global Settings**:
- Layout: BSP (binary space partitioning)
- Focus: Manual (mouse doesn't follow)
- Padding: 4px all sides
- External bar: 37px (for SketchyBar)
- Animation duration: 0.0 (instant)

### Event Handlers (Reference)

#### `application-activated.zsh` (CURRENTLY DISABLED)

> **Status**: This event handler is **not active** because the `application_activated` signal is disabled in yabairc due to causing system-wide minimize bugs.

**Purpose**: Auto-stack related apps when >3 windows on space

**Logic**:
1. Check if >3 non-minimized, non-floating windows
2. If yes, stack pairs:
   - VSCode + Tower (Git client)
   - Chrome + Transmit (FTP)

**Bug Prevention**:
- **Rate Limiting**: Lock file prevents re-exec within 2 seconds
- **Debug Logging**: All operations logged
- **Cascade Prevention**: Exit early if recently executed

**Why Disabled**: Window queries (`yabai -m query --windows`) in this script disturb minimized windows across all applications, causing them to unexpectedly deminimize.

**Documentation**: See `.claude/YABAI_MINIMIZE_BUG/` for complete bug investigation, root cause analysis, and solution options.

### Bootstrap: `yabai/bootstrap.sh`

**Steps**:
1. Verify Homebrew
2. Install yabai (from koekeishiya/formulae tap)
3. Install borders (from felixkratz/formulae tap)
4. Stop service
5. Upgrade to latest
6. Calculate SHA256 hash
7. Create/update sudoers (`/private/etc/sudoers.d/yabai`)
8. Load scripting addition
9. Configure macOS settings
10. Start service

**Security**: Sudoers uses SHA256 hash for passwordless `sudo yabai --load-sa`

## System Utilities

### Backup/Restore (`system/functions.zsh`)

**Commands**:
- `new_bak FILE` - Create incremental backup (.bak0, .bak1, ...)
- `restore_bak FILE|BACKUP` - Restore from backup
- `clean_bak [-r] [DIR]` - Remove backup directories

**Features**:
- Works with files and directories
- Incremental numbered backups
- Automatic safety backup before restore
- Relative path display
- Error handling with cleanup

### Host Management

**Commands**:
- `add_host IP HOSTNAME` - Add entry to /etc/hosts
- `remove_host HOSTNAME` - Remove entry

**Safety**:
- File locking (prevent race conditions)
- IP validation
- Exact hostname matching
- Automatic backup
- Requires sudo

### Git Utilities (`bin/git-*`)

15 git utility commands:
- `git-amend` - Quick amend
- `git-undo` - Undo last commit (keep changes)
- `git-nuke` - Reset hard to origin
- `git-up` - Smart pull with rebase
- `git-promote` - Promote branch to master
- `git-delete-local-merged` - Clean merged branches
- And 9 more...

## Environment Variables

### XDG Base Directory

```bash
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_CACHE_HOME="$HOME/.cache"
XDG_STATE_HOME="$HOME/.local/state"
XDG_RUNTIME_DIR="/tmp"
XDG_BIN_HOME="$HOME/.local/bin"
```

### Dotfiles-Specific

```bash
ZDOTDIR="$XDG_CONFIG_HOME/.zsh"
ZSH="$XDG_CONFIG_HOME/.dotfiles/zsh-setup-scripts"
```

### Tool-Specific (XDG-compliant)

```bash
HISTFILE="$XDG_STATE_HOME/zsh/history"
CARGO_HOME="$XDG_DATA_HOME/cargo"
NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
```

## File Naming Conventions

### Configuration Files

- `env.zsh` - Environment variables and initialization
- `aliases.zsh` - Command aliases
- `functions.zsh` - Shell functions
- `completion.zsh` - Tab completion setup
- `config.zsh` - Tool configuration
- `fpath.zsh` - Function path setup

### Script Files

- `*.sh` - Bash/Zsh scripts (executable)
- `*.zsh` - Zsh-specific scripts
- `install.sh` - Tool installation
- `bootstrap.sh` - Service setup
- `is_installed.sh` - Installation checker

### Test Files

- `*_spec.sh` - ShellSpec test files
- `spec_helper.sh` - Shared test utilities

## Common Patterns

### Safe File Sourcing

```bash
try_source "$file" warn  # Log warning if missing
try_source "$file" error # Log error if missing
```

### Environment Variable Export

```bash
export_n_log VAR "value"  # Export and log (with redaction)
```

### Path Management

```bash
add_to PATH "/usr/local/bin"  # Add without duplicates
```

### Conditional Loading

```bash
get_zsh_files env && {
    for file in $matched_files; do
        try_source "$file" warn
    done
} || log_warn "No env files found"
```

### Debug Logging

```bash
if is_debug_enabled; then
    log_debug "Detailed debug information"
fi
```

### Skip Flags (Boolean Strings)

All skip flags use boolean string values for explicitness:

```bash
# Initialize skip flag (default false)
typeset -gx SKIP_UPDATES=false
(( ${+opts[-u]} || ${+opts[--skip-updates]} )) && SKIP_UPDATES=true

# Check skip flag
if [[ "${SKIP_UPDATES:-false}" == "true" ]]; then
  log_skip "Skipping updates"
  return 0
fi
```

**Why Boolean Strings?**
- More explicit than numeric (0/1) - immediately clear what value means
- Safer defaults with `${VAR:-false}` pattern
- Consistent with shell conventions for exported variables
- Better readability: `true`/`false` vs `1`/`0`

### Option Parsing with zparseopts

```bash
# Declare associative array for options
local -A opts

# Parse options (check existence with ${+opts[KEY]})
zparseopts -D -E -F -A opts -- \
  d -skip-dotbot \
  u -skip-updates \
  || return 1

# Check if option was provided using existence check
(( ${+opts[-d]} || ${+opts[--skip-dotbot]} )) && SKIP_DOTBOT=true
```

## Key Relationships

### Installation Chain

```
install-all → run-dotbot → DotBot → Create dirs/symlinks
           ↓
           └→ Discover install.sh scripts → Run each
           ↓
           └→ Setup services → yabai/skhd/sketchybar
```

### Shell Loading Chain

```
~/.zshenv → helpers.zsh → helpers_logging.zsh (1014 lines)
         ↓
         └→ Set XDG vars → Add to PATH → Source fpath.zsh

~/.zshrc → homebrew/env.zsh → zsh/config.zsh → .localrc
        ↓
        └→ Load env.zsh → other → aliases → functions
        ↓
        └→ compinit → completions → zoxide
```

### Yabai Event Chain

```
macOS Window Event → Yabai Signal → Event Script
                                  ↓
                                  ├→ application_activated → [DISABLED - minimize bug]
                                  ├→ window_created → [DISABLED - minimize bug]
                                  ├→ window_focused → Debug log + SketchyBar
                                  ├→ window_minimized/deminimized → Debug log
                                  └→ application_front_switched → Debug log
```

## Security Patterns

### Installer Whitelist Validation

For security-sensitive operations that dynamically execute scripts:

```bash
# Define whitelist of approved installer paths
local allowed_installer_paths=(
  "zsh-setup-scripts/homebrew/install.sh"
  "zsh-setup-scripts/osx/install.sh"
)

# Build list with validation using null-terminated find
local -a installers
while IFS= read -r -d '' installer; do
  local is_allowed=false
  for allowed_path in "${allowed_installer_paths[@]}"; do
    if [[ "$installer" == "./$allowed_path" || "$installer" == "$allowed_path" ]]; then
      is_allowed=true
      break
    fi
  done

  if [[ "$is_allowed" == "true" ]]; then
    installers+=("$installer")
  else
    log_skip "Skipping non-whitelisted installer: $installer"
  fi
done < <(find . -name install.sh -print0)
```

### Sudo Keep-Alive with Timeout

Safe sudo privilege management with automatic cleanup:

```bash
# Request sudo once
sudo -v || exit 1

# Keep sudo alive with timeout and parent process check
# Max 60 iterations × 30 seconds = 30 minutes
(for i in {1..60}; do
  sudo -n true 2>/dev/null || break      # Refresh sudo or exit if fails
  kill -0 $$ 2>/dev/null || break        # Exit if parent process gone
  sleep 30
done) &
SUDO_KEEPALIVE_PID="$!"

# Cleanup function to kill background process
cleanup() {
  if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
    kill "$SUDO_KEEPALIVE_PID" &>/dev/null
  fi
}
trap cleanup EXIT
```

**Why This Pattern?**
- **Timeout**: Prevents infinite sudo token refresh (30 minutes max)
- **Parent Check**: `kill -0 $$` ensures we stop if parent exits (prevents runaway processes)
- **Graceful Cleanup**: Trap ensures background process is killed on exit

### Variable Existence Checking

Safe way to check if variables are set (vs empty):

```bash
# Check if variable exists (even if empty)
[[ -n "${VAR+x}" ]] && unset VAR

# Check if variable is non-empty
[[ -n "$VAR" ]] && process "$VAR"
```

## Troubleshooting

### Homebrew not found

- Check if `/opt/homebrew/bin/brew` (Apple Silicon) or `/usr/local/bin/brew` (Intel) exists
- Run `homebrew/install.sh` manually
- Restart shell

### Install script fails or installer skipped

- Check if installer is in whitelist (see `install-all` line 191-195)
- Add new installer to whitelist if needed
- Check exit code: `echo $?` after running `./install-all`

### Yabai not working

- Check scripting addition: `sudo yabai --load-sa`
- Verify sudoers: `cat /private/etc/sudoers.d/yabai`
- View debug logs: `tail -f /tmp/yabai_minimize_debug.log`
- Restart service: `yabai --restart-service`

### Shell functions not available

- Verify `.zshenv` sourced: `echo $ZDOTDIR`
- Check permissions: `ls -l ~/.zshenv`
- Run with debug: `LOG_LEVEL=DEBUG LOG_ENABLED=true zsh`

### Tests failing

- Install ShellSpec: `brew install shellspec`
- Check zsh version: `zsh --version` (need 5.0+)
- Run single test: `shellspec spec/logging_helpers/formatting_spec.sh`

## Adding New Tools

1. Create directory: `zsh-setup-scripts/[tool]/`
2. Add configuration files:
   - `env.zsh` - Environment setup
   - `aliases.zsh` - Aliases (if needed)
   - `functions.zsh` - Functions (if needed)
   - `completion.zsh` - Completions (if needed)
   - `install.sh` - Installation (if needed)
3. Update `dotbot.conf.yaml` if symlinks needed
4. Test with debug logging enabled
5. Update this documentation

## Code Style

1. **Use existing patterns from similar files** - Follow established conventions
2. **Add error handling** - Fail gracefully, track exit codes
3. **Validate input** - Never trust user input, use whitelists for security-sensitive operations
4. **Quote variables** - Always quote expansions (`"$var"`, not `$var`)
5. **Document functions** - Use comprehensive docstrings
6. **Use logging framework** - All output goes through logging functions
7. **Boolean flags** - Use boolean string values (`true`/`false`) not numeric (0/1)
8. **Check option existence** - Use `(( ${+opts[KEY]} ))` pattern with zparseopts
9. **Exit codes** - Return 0 for success, 1 for failure; track throughout script
10. **Security** - Whitelist validation, parent process checks, timeouts on background processes

## Resources

### Internal Documentation

- `README.md` - General overview
- `NEW_MACHINE.md` - Quick setup guide
- `.claude/README.md` - Logging framework refactoring documentation
- `.claude/SHELLSPEC/` - ShellSpec testing reference and troubleshooting
- `.claude/YABAI_MINIMIZE_BUG/` - Yabai minimize bug investigation (9 files)
- `.claude/YABAI_SKHD/` - Yabai/SKHD configuration reference and fixes (4 files)
- `.claude/agents/` - Custom Claude Code agent configurations
- `zsh-setup-scripts/README.md` - Shell scripts guide
- `brewfiles/README.txt` - Homebrew usage instructions

### External References

- **Homebrew**: https://brew.sh/
- **DotBot**: https://github.com/anishathalye/dotbot
- **Yabai**: https://github.com/koekeishiya/yabai
- **SKHD**: https://github.com/koekeishiya/skhd
- **SketchyBar**: https://github.com/FelixKratz/SketchyBar
- **ShellSpec**: https://shellspec.info/
- **XDG Base Directory**: https://specifications.freedesktop.org/basedir-spec/latest/
