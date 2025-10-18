# Zsh Setup Scripts

Modular shell configuration system for macOS with organized tool integrations and utilities.

## Overview

This directory contains a modular zsh configuration organized by functionality. Each subdirectory handles a specific tool, language, or feature area. Scripts are designed to be:

- **Modular**: Each tool/feature in its own directory
- **Safe**: Error handling, input validation, race condition prevention
- **Portable**: Works on both Intel and Apple Silicon Macs
- **Self-documenting**: Comprehensive inline documentation

## Directory Structure

```
zsh-setup-scripts/
├── cheat/           # cheat.sh integration (env, completion)
├── docker/          # Docker aliases and helpers
├── functions/       # Standalone utility functions (extract, gf, c)
├── fzf/             # Fuzzy finder integration
├── git/             # Git aliases, completions, and helpers
├── gnupg/           # GPG environment setup
├── go/              # Go language environment
├── grc/             # Generic colorizer setup
├── homebrew/        # Homebrew environment and path detection
├── jupyter/         # Jupyter notebook environment
├── lazyman/         # Lazyman neovim manager integration
├── misc/            # Miscellaneous aliases
├── ngrok/           # ngrok completion
├── node/            # Node.js environment
├── nvim/            # Neovim aliases and helpers
├── osx/             # macOS-specific configuration
├── pyenv/           # Python version management
├── script/          # Bootstrap and setup scripts
├── sketchybar/      # SketchyBar integration
├── skhd/            # Simple hotkey daemon setup
├── starship/        # Starship prompt configuration
├── superfile/       # Superfile file manager integration
├── system/          # Core system utilities (backups, hosts, etc.)
├── warp/            # Warp terminal integration
├── yabai/           # Yabai window manager setup
├── zoxide/          # Smart directory navigation
└── zsh/             # Core zsh configuration (aliases, completion, prompt)
```

## Core Features

### Backup & Restore System

Located in `system/functions.zsh`, provides version-controlled backups:

```bash
# Create a backup
new_bak myfile.txt
# Creates: .backups/myfile.txt.bak0

# Make changes, create another backup
new_bak myfile.txt
# Creates: .backups/myfile.txt.bak1

# Restore from latest backup
restore_bak myfile.txt
# Restores from .backups/myfile.txt.bak1

# Or restore from specific backup
restore_bak .backups/myfile.txt.bak0

# Clean up backups
clean_bak           # Remove .backups in current directory
clean_bak -r .      # Remove all .backups recursively
```

**Features:**
- Incremental numbered backups (.bak0, .bak1, .bak2, ...)
- Works with both files and directories
- Automatic safety backup before restore
- Error handling with cleanup on failure
- Relative path display for clarity

### Host Management

Safe `/etc/hosts` file manipulation:

```bash
# Add a host entry
add_host 192.168.1.10 myserver.local
# Uses file locking to prevent race conditions

# Remove a host entry
remove_host myserver.local
# Exact hostname matching only
```

**Safety Features:**
- File locking prevents concurrent modification
- IP address validation
- Exact hostname matching (won't match substrings)
- Automatic backup before changes

### Utility Functions

**Directory Navigation:**
```bash
mkd new-project      # Create directory and cd into it
rmd old-project      # Remove directory and cd to parent
c project-name       # Quick cd to project in $PROJECTS
```

**File Operations:**
```bash
extract archive.tar.gz    # Auto-detect and extract any archive
fs /path/to/file         # Get human-readable file size
o file.txt               # Open with default application
```

**System Info:**
```bash
colormap             # Display all terminal colors
```

## Tool Integrations

### Homebrew
- Cross-platform path detection (Intel + Apple Silicon)
- Automatically adds Homebrew to PATH if available

### Zoxide
- Smart directory jumping with `z`
- Enhanced `cd` command with automatic `ls` after change
- Falls back gracefully if not installed

### FZF
- Fuzzy finding integration
- Error handling for missing configuration

### Superfile
- Directory persistence across sessions
- Cross-platform compatibility

### Git
- Extensive alias collection
- Safe operations (detached HEAD detection)
- Enhanced diff with color support

## Installation

These scripts are typically loaded via a main `.zshrc` file:

```bash
# In your ~/.zshrc or xdg_config/zsh/.zshrc
for config_file in ~/dotfiles/zsh-setup-scripts/**/*.zsh; do
  source "$config_file"
done
```

Or selectively:

```bash
# Load specific categories
source ~/dotfiles/zsh-setup-scripts/system/*.zsh
source ~/dotfiles/zsh-setup-scripts/git/*.zsh
source ~/dotfiles/zsh-setup-scripts/homebrew/*.zsh
```

## Configuration

Many integrations check for tool availability before loading:

```bash
# Example: fzf only loads if installed
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi
```

### Environment Variables

Set these before loading scripts to customize behavior:

```bash
# Project directory for `c` function
export PROJECTS="$HOME/projects"

# FZF customization
export FZF_DEFAULT_OPTS="--height 40% --reverse"

# Logging level (if using helpers_logging.zsh)
export LOG_LEVEL="INFO"
export LOG_ENABLED=true
```

## File Naming Convention

Files follow a consistent naming pattern:

- `env.zsh` - Environment variables and tool initialization
- `aliases.zsh` - Command aliases
- `functions.zsh` - Shell functions
- `completion.zsh` - Tab completion setup
- `*.sh` - Bash scripts (for bootstrapping)

## Development

### Code Quality Standards

1. **Error Handling**: All functions check for errors and fail gracefully
2. **Input Validation**: User input is validated before use
3. **Quoting**: All variable expansions are quoted
4. **Documentation**: Public functions have comprehensive docstrings
5. **Portability**: Uses `#!/usr/bin/env zsh` shebang

### Example Function Documentation

```bash
##############################################################################
# function_name - Brief description
#
# Detailed description of what the function does, including any important
# behaviors or edge cases.
#
# Args:
#   $1 - First argument description
#   $2 - Second argument description
#
# Returns:
#   0 on success, 1 on failure
#
# Examples:
#   function_name arg1 arg2
##############################################################################
function function_name() {
  # Implementation
}
```

## Testing

Key areas to test when making changes:

1. **Backup/Restore System**
   - Files with spaces in names
   - Directory backups
   - Error handling with full disk
   - Restore with existing target

2. **Host Management**
   - Concurrent modifications
   - Invalid IP addresses
   - Hostname with similar names

3. **Platform Compatibility**
   - Intel Mac (/usr/local/bin/brew)
   - Apple Silicon Mac (/opt/homebrew/bin/brew)
   - Missing tools graceful fallback

## Troubleshooting

### Common Issues

**Functions not available:**
- Ensure scripts are sourced in correct order
- Check for syntax errors: `zsh -n script.zsh`
- Verify file has execute permissions

**Tool not found:**
- Most integrations check for tool availability
- Install missing tools via Homebrew
- Check PATH contains Homebrew bin directory

**Permission denied:**
- Host management requires sudo
- Backup system needs write permissions

**Homebrew not detected:**
- Verify Homebrew installation: `which brew`
- Check PATH: `echo $PATH`
- Restart shell after Homebrew install

## Contributing

When adding new integrations:

1. Create a new directory for the tool
2. Follow naming conventions (env.zsh, aliases.zsh, etc.)
3. Add error handling and input validation
4. Document all public functions
5. Test on both Intel and Apple Silicon if possible
6. Update this README with the new integration

## License

Part of personal dotfiles - modify freely for your own use.

## Related Files

- `../helpers_logging.zsh` - Logging framework used by some scripts
- `../xdg_config/zsh/.zshrc` - Main zsh configuration
- `../brewfiles/` - Homebrew package definitions
- `../.claude/CODE_REVIEW_ZSH_SETUP_SCRIPTS.md` - Detailed code review
- `../.claude/CODE_REVIEW_FIXES_PROGRESS.md` - Fix implementation progress
