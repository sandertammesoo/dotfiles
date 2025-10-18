# Backup & Restore System Guide

The dotfiles backup system provides a safe, versioned approach to managing file and directory backups directly within your filesystem.

## Overview

The backup system creates incremental, numbered backups in `.backups` directories alongside your original files. This allows you to:

- Experiment with configuration changes safely
- Roll back to any previous version
- Keep a local history without git commits
- Backup entire directories with their structure intact

## Quick Start

```bash
# Create a backup
new_bak ~/.zshrc

# Make changes to ~/.zshrc
vim ~/.zshrc

# Create another backup (keeps both versions)
new_bak ~/.zshrc

# Restore from latest backup
restore_bak ~/.zshrc

# Clean up old backups
clean_bak ~
```

## Functions

### `new_bak <file_or_directory>`

Creates a new backup with an incremental number.

**Examples:**

```bash
# Backup a file
new_bak myconfig.conf
# Creates: .backups/myconfig.conf.bak0

# Make changes, backup again
new_bak myconfig.conf
# Creates: .backups/myconfig.conf.bak1

# Backup a directory
new_bak ~/.config/nvim
# Creates: ~/.config/.backups/nvim.bak0/
```

**Features:**
- Automatically creates `.backups` directory
- Incremental numbering (.bak0, .bak1, .bak2, ...)
- Works with files and directories
- Preserves directory structure
- Error handling with cleanup on failure

**Output:**
```
Created new backup: '.backups/myconfig.conf.bak0'
```

### `restore_bak <backup_or_original>`

Restores a file or directory from backup.

**Two modes of operation:**

1. **Restore from latest backup** (specify original file):
```bash
restore_bak myconfig.conf
# Finds and restores from .backups/myconfig.conf.bakN (highest N)
```

2. **Restore from specific backup** (specify backup file):
```bash
restore_bak .backups/myconfig.conf.bak0
# Restores from the exact backup specified
```

**Safety Features:**
- Creates a new backup of current file before restoring
- Won't lose your current version
- Shows clear messages about what's happening

**Examples:**

```bash
# Working with configuration file
echo "version 1" > config.txt
new_bak config.txt

echo "version 2" > config.txt
new_bak config.txt

echo "version 3" > config.txt

# Restore latest backup (version 2)
restore_bak config.txt
# Current version (version 3) is backed up as .bak2
# File now contains "version 2"

# Restore specific older version
restore_bak .backups/config.txt.bak0
# File now contains "version 1"
```

**Output:**
```
Created new backup from 'config.txt': .backups/config.txt.bak2
Removing file 'config.txt' before restore...
Restored 'config.txt' from '.backups/config.txt.bak1'
```

### `clean_bak [-r] [directory]`

Removes backup directories to free up space.

**Usage:**

```bash
# Clean backups in current directory
clean_bak

# Clean backups in specific directory
clean_bak ~/projects/myapp

# Recursively clean all backups in a directory tree
clean_bak -r ~/projects
```

**Examples:**

```bash
# Remove .backups in current directory only
cd ~/projects/myapp
clean_bak
# Removes: ~/projects/myapp/.backups/

# Remove all .backups under projects (recursive)
clean_bak -r ~/projects
# Removes:
#   ~/projects/.backups/
#   ~/projects/app1/.backups/
#   ~/projects/app2/config/.backups/
#   ... and any others found
```

**Options:**
- `-r` - Recursive: remove all `.backups` directories found
- `-h, --help` - Show help message

**Output:**
```
Removing '.backups'...
```

## Use Cases

### Configuration File Management

Perfect for managing dotfiles:

```bash
# Before editing your shell config
new_bak ~/.zshrc

# Make experimental changes
vim ~/.zshrc

# Test it
source ~/.zshrc

# Didn't work? Restore it
restore_bak ~/.zshrc

# Worked great? Keep it and create a new backup
new_bak ~/.zshrc
```

### Directory Backups

Backup entire configuration directories:

```bash
# Backup neovim config before trying new plugins
new_bak ~/.config/nvim

# Install and test new plugins
vim ~/.config/nvim/init.lua

# Not working out? Restore it
restore_bak ~/.config/nvim

# Everything works? Keep it
new_bak ~/.config/nvim
```

### Version History Without Git

Keep a local history of important files:

```bash
# Daily backups of important file
new_bak ~/Documents/important.txt  # Monday
new_bak ~/Documents/important.txt  # Tuesday
new_bak ~/Documents/important.txt  # Wednesday

# Later: view all versions
ls -la ~/Documents/.backups/
# important.txt.bak0  (Monday)
# important.txt.bak1  (Tuesday)
# important.txt.bak2  (Wednesday)

# Restore from any version
restore_bak ~/Documents/.backups/important.txt.bak0
```

### Safe Refactoring

When refactoring code files:

```bash
# Backup before major refactoring
new_bak src/main.rs

# Refactor
vim src/main.rs

# Create checkpoint
new_bak src/main.rs

# Refactor more
vim src/main.rs

# Broke something? Restore checkpoint
restore_bak src/main.rs
```

## Understanding Backup Locations

Backups are stored in `.backups` directories adjacent to the original file:

```
~/projects/myapp/
├── config.json
├── .backups/
│   ├── config.json.bak0
│   ├── config.json.bak1
│   └── config.json.bak2
└── src/
    ├── main.rs
    └── .backups/
        └── main.rs.bak0
```

Each directory level has its own `.backups` folder containing backups of files in that directory.

## Backup Naming

Backups use incremental numbering:

- `.bak0` - First backup
- `.bak1` - Second backup
- `.bak2` - Third backup
- ... and so on

The system automatically finds the next available number.

## How Restore Works

When you run `restore_bak myfile.txt`:

1. **Find latest backup**: Searches `.backups/myfile.txt.bak*` for highest number
2. **Safety backup**: Creates new backup of your current file (`.bakN+1`)
3. **Remove current**: Safely removes current file/directory
4. **Restore**: Copies backup to original location

This ensures you never lose data - your current version is always backed up first.

## Best Practices

### When to Use Backups

✅ **Good uses:**
- Before editing system-critical configs
- When experimenting with new configurations
- Creating checkpoints during development
- Keeping local version history

❌ **Not recommended:**
- As a replacement for git version control
- For files that change very frequently
- For very large binary files
- For files in version-controlled repositories (use git instead)

### Maintenance

```bash
# Periodically clean up old backups
clean_bak -r ~/projects

# Or be selective
clean_bak ~/projects/completed-project

# Review backups before cleaning
ls -laR ~/projects/**/.backups/
```

### Combining with Git

Backups complement git, they don't replace it:

```bash
# Use backups for quick local experiments
new_bak src/feature.rs
vim src/feature.rs
# Test...
restore_bak src/feature.rs  # Quick rollback

# Use git for permanent changes
vim src/feature.rs
git add src/feature.rs
git commit -m "Add feature"
```

## Advanced Usage

### Scripting with Backups

```bash
#!/usr/bin/env zsh

# Backup all config files before system update
for config in ~/.zshrc ~/.vimrc ~/.tmux.conf; do
  new_bak "$config"
done

# Run system update
brew upgrade

# If something breaks, restore all
# for config in ~/.zshrc ~/.vimrc ~/.tmux.conf; do
#   restore_bak "$config"
# done
```

### Viewing Backup Differences

```bash
# Compare current with latest backup
diff myfile.txt .backups/myfile.txt.bak0

# Compare two backups
diff .backups/myfile.txt.bak0 .backups/myfile.txt.bak1

# Use your favorite diff tool
code --diff myfile.txt .backups/myfile.txt.bak0
```

### Finding All Backups

```bash
# List all backup directories
find ~ -type d -name ".backups"

# Count total backup files
find ~ -name "*.bak*" | wc -l

# Find large backups
find ~ -name "*.bak*" -type f -exec du -h {} \; | sort -h
```

## Error Messages

Common error messages and their meanings:

```
Error: Failed to copy file to '.backups/file.txt.bak0'
```
- Disk might be full
- Permission issues
- Partial backup will be cleaned up automatically

```
Error: No backups found for 'file.txt' in '.backups'
```
- File has never been backed up
- Run `new_bak file.txt` first

```
Warning: The original item 'file.txt' does not exist. Restoring anyway.
```
- Original file was deleted
- Backup will be restored to its original location

## Troubleshooting

**Backup not created:**
- Check disk space: `df -h`
- Verify write permissions: `ls -la .`
- Look for error messages

**Restore not working:**
- Verify backup exists: `ls .backups/`
- Check filename spelling
- Ensure you have write permissions

**Too many backups:**
- Use `clean_bak -r` to remove all
- Or manually: `rm -rf .backups/`
- Consider using git for long-term history

## Implementation Details

The backup system consists of helper functions:

- `_sanitize_backup_path()` - Removes ANSI codes and newlines
- `_parse_backup_path()` - Extracts original path from backup
- `_backup_existing_target()` - Creates safety backup
- `_clear_restore_target()` - Safely removes current file
- `_perform_restore()` - Executes the copy operation

All functions include error handling and cleanup on failure.

## See Also

- `man cp` - Copy command used for backups
- `man find` - Finding backup directories
- Git version control for permanent history
- Time Machine for system-level backups
