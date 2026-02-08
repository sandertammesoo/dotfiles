#!/usr/bin/env zsh
# System utility functions for file/directory management, backups, and hosts
#
# Note: Verbose logging disabled by default
# To enable detailed logging, uncomment: log_trace "$(basename "${(%):-%x}")"

##############################################################################
# to_relative: Convert an absolute or relative path (TARGET) into a relative
#             path from the current working directory (PWD). Works even if
#             TARGET doesn’t yet exist (no cd necessary).
#
# Examples:
#   If PWD=/Users/sander/projects/test_backup_helper_functions
#   to_relative /Users/sander => ../..
#   to_relative .backups/test.txt.bak0 => ./.backups/test.txt.bak0
#   to_relative ../../some/other/dir => ../../some/other/dir
##############################################################################
function to_relative() {
  local target="$1"

  # 1) If target is not absolute (no leading /), make it absolute via $PWD
  #    e.g. "foo/bar" => "/current/dir/foo/bar"
  [[ "$target" != /* ]] && target="$PWD/$target"

  # 2) Base is just $PWD as an absolute
  local base="$PWD"

  # 3) Split both paths on '/' into arrays
  #    Turn leading '/' into empty first elements, so we handle root properly
  local -a TPARTS
  local -a BPARTS

  # Remove any trailing '/' so we don't get empty last elements
  target="${target%%/}"
  base="${base%%/}"

  TPARTS=( "${(@s:/:)target}" )
  BPARTS=( "${(@s:/:)base}" )

  # 4) Find common prefix
  local i=1
  local tcount=$#TPARTS
  local bcount=$#BPARTS
  local min_len=$(( tcount < bcount ? tcount : bcount ))

  while (( i <= min_len )) && [[ "${TPARTS[i]}" == "${BPARTS[i]}" ]]; do
    (( i++ ))
  done

  # 5) Add ../ for each remaining segment in base
  #    (i.e. go “up” until we reach the common ancestor)
  local result=""
  local j=$i
  while (( j <= bcount )); do
    [[ -n "${BPARTS[j]}" ]] && result+="../"
    (( j++ ))
  done

  # 6) Append leftover TPARTS
  while (( i <= tcount )); do
    result+="${TPARTS[i]}"
    (( i++ ))
    (( i <= tcount )) && result+="/"
  done

  # 7) If empty => same directory => "."
  echo "${result:-.}"
}

##############################################################################
# Create a new backup in the .backups directory
##############################################################################
function new_bak() {
    local target="$1"
    if [[ -z "$target" ]]; then
        echo "Usage: new_bak <file_or_folder>"
        return 1
    fi

    local dir
    dir="$(dirname "$target")/.backups"
    mkdir -p "$dir"

    local name
    name="$(basename "$target")"

    # Figure out a free .bakN name
    local i=0
    while [[ -e "$dir/${name}.bak${i}" ]]; do
        ((i++))
    done
    local backup_path="$dir/${name}.bak${i}"

    # If it's a directory => cp -r; otherwise cp
    if [[ -d "$target" ]]; then
        mkdir -p "$backup_path" || {
            echo "Error: Failed to create backup directory '$backup_path'"
            return 1
        }
        # Copy contents (.* for hidden files if needed)
        cp -r "$target"/. "$backup_path" || {
            echo "Error: Failed to copy directory contents to '$backup_path'"
            rm -rf "$backup_path"  # Clean up partial backup
            return 1
        }
    else
        cp "$target" "$backup_path" || {
            echo "Error: Failed to copy file to '$backup_path'"
            return 1
        }
    fi

    echo "Created new backup: '$(to_relative "$backup_path")'"
}

##############################################################################
# restore_bak <backup_or_original>
#  - If <backup_or_original> ends with ".bak<number>", restore that file.
#  - Otherwise treat it as the original filename (e.g. "test.txt"),
#    find its latest .backups/test.txt.bak<number> in the same folder,
#    and restore that one.
##############################################################################
function restore_bak() {
    local input="$1"

    if [[ -z "$input" ]]; then
        echo "Usage: restore_bak <backup_file_or_original_file>"
        return 1
    fi

    # Function to strip ANSI codes/newlines just in case
    local sanitize='s/\x1B\[[0-9;]*m//g'
    input="$(echo "$input" | tr -d '\n' | sed "$sanitize")"
    
    # Break down input into directory and filename
    local dir name backups_dir
    dir="$(dirname "$input")"
    name="$(basename "$input")"
    backups_dir="$dir/.backups"

    # If input looks like "file.txt.bak1" or "folderA.bak0", try resolving it
    if [[ "$name" =~ \.bak[0-9]+$ ]]; then
        local original_name="${name%.bak*}"  # Strip ".bakN"
        local backup_path=""
        
        # Check if the backup exists in the same directory
        if [[ -e "$dir/$name" ]]; then
            backup_path="$dir/$name"
        elif [[ -e "$backups_dir/$name" ]]; then
            backup_path="$backups_dir/$name"
        fi

        if [[ -z "$backup_path" ]]; then
            echo "Error: Backup '$name' not found in '$dir' or '$backups_dir'."
            return 1
        fi

        echo "Using backup '$backup_path' to restore '$original_name'."
        _restore_bak_file "$backup_path"
        return 0
    fi
    
    # Otherwise, treat input as an original file and find its latest backup
    if [[ ! -d "$backups_dir" ]]; then
        echo "Error: No .backups folder found for '$input'. Nothing to restore."
        return 1
    fi

    # Find the highest-numbered .bakN for that file
    # e.g. .backups/test.txt.bak0, .backups/test.txt.bak1, ...
    local latest_bak=""
    local latest_num=-1
    
    for f in "$backups_dir/${name}.bak"*; do
        # If the glob had no matches, skip
        [[ -e "$f" ]] || continue

        # Extract trailing digits. E.g. "folder1.bak0" => "0", "folder1.bak12" => "12"
        local bn="$(basename "$f")"
        local num="${bn##*.bak}"  # everything after ".bak"

        # Must be pure digits
        [[ "$num" =~ ^[0-9]+$ ]] || continue

        # Compare
        if (( num > latest_num )); then
            latest_num=$num
            latest_bak="$f"
        fi
    done

    if (( latest_num < 0 )) || [[ -z "$latest_bak" ]]; then
        echo "Error: No backups found for '$input' in '$backups_dir'."
        return 1
    fi

    echo "Using latest backup '$latest_bak' to restore '$input'."
    _restore_bak_file "$latest_bak"
}

##############################################################################
# _sanitize_backup_path - Remove ANSI codes and newlines from path
#
# Internal helper for restore operations. Cleans up paths that may contain
# terminal escape sequences or unwanted whitespace.
#
# Args:
#   $1 - Path to sanitize
#
# Returns:
#   Sanitized path string
##############################################################################
function _sanitize_backup_path() {
    echo "$1" | tr -d '\n' | sed 's/\x1B\[[0-9;]*m//g'
}

##############################################################################
# _parse_backup_path - Extract original path from backup path
#
# Internal helper that determines the original file/directory path from
# a backup path in the .backups directory.
#
# Args:
#   $1 - Backup path (e.g., /path/to/.backups/file.txt.bak0)
#
# Returns:
#   Original path that the backup came from
##############################################################################
function _parse_backup_path() {
    local backup="$1"
    local backup_dir="$(dirname "$backup")"
    local backup_name="$(basename "$backup")"
    local original_name="${backup_name%.bak*}"
    
    # Get parent directory of .backups folder
    local original_dir="$(builtin cd "$backup_dir/.." && builtin pwd)"
    
    echo "$original_dir/$original_name"
}

##############################################################################
# _backup_existing_target - Create backup of existing file before restore
#
# Internal helper that backs up the current file/directory before restoring
# an older version. This ensures we don't lose the current state.
#
# Args:
#   $1 - Path to back up
#
# Returns:
#   0 on success, 1 on failure
##############################################################################
function _backup_existing_target() {
    local target="$1"
    
    [[ ! -e "$target" ]] && return 0  # Nothing to backup
    
    local prev_bak="$(new_bak "$target" | awk '{print $NF}')" || {
        echo "Error: Failed to create backup of existing target"
        return 1
    }
    
    echo "Created new backup from '$(to_relative "$target")': $(to_relative "$prev_bak")"
    return 0
}

##############################################################################
# _clear_restore_target - Remove existing file/directory contents
#
# Internal helper that removes the existing target to prepare for restore.
# For directories, removes contents but keeps the directory structure.
#
# Args:
#   $1 - Path to clear
#
# Returns:
#   0 on success
##############################################################################
function _clear_restore_target() {
    local target="$1"
    
    if [[ -d "$target" ]]; then
        echo "Cleaning out '$(to_relative "$target")' before restore..."
        find "$target" -mindepth 1 -delete 2>/dev/null
    else
        echo "Removing file '$(to_relative "$target")' before restore..."
        rm -f "$target"
    fi
}

##############################################################################
# _perform_restore - Copy backup contents to original location
#
# Internal helper that performs the actual file/directory copy operation
# from backup to original location.
#
# Args:
#   $1 - Backup path (source)
#   $2 - Original path (destination)
#
# Returns:
#   0 on success, 1 on failure
##############################################################################
function _perform_restore() {
    local backup="$1"
    local original="$2"
    
    if [[ -d "$backup" ]]; then
        mkdir -p "$original" || {
            echo "Error: Failed to create directory '$original'"
            return 1
        }
        cp -r "$backup"/. "$original" || {
            echo "Error: Failed to restore directory from '$backup'"
            return 1
        }
    else
        cp "$backup" "$original" || {
            echo "Error: Failed to restore file from '$backup'"
            return 1
        }
    fi
    
    return 0
}

##############################################################################
# _restore_bak_file - Restore a file from a backup
#
# Internal function called by restore_bak. Handles the actual restoration
# process including sanitization, backup creation, and file copying.
# Uses helper functions for better modularity and testability.
#
# Args:
#   $1 - Backup file/directory path
#
# Returns:
#   0 on success, 1 on failure
##############################################################################
function _restore_bak_file() {
    local backup="$1"

    if [[ -z "$backup" || ! -e "$backup" ]]; then
        echo "Usage: _restore_bak_file <backup_file_or_folder>"
        return 1
    fi

    # Sanitize the backup path
    backup="$(_sanitize_backup_path "$backup")"
    
    # Determine the original path from the backup path
    local original_path="$(_parse_backup_path "$backup")"

    # Ensure parent directory exists
    mkdir -p "$(dirname "$original_path")" || {
        echo "Error: Failed to create parent directory for '$original_path'"
        return 1
    }

    # Backup the existing target if it exists
    if [[ -e "$original_path" ]]; then
        _backup_existing_target "$original_path" || return 1
        _clear_restore_target "$original_path"
    else
        echo "Warning: The original item '$(to_relative "$original_path")' does not exist. Restoring anyway."
    fi

    # Perform the actual restore
    _perform_restore "$backup" "$original_path" || return 1

    echo "Restored '$(to_relative "$original_path")' from '$(to_relative "$backup")'"
    return 0
}

##############################################################################
# clean_bak [ -r ] [ target_dir ]
#   If no arguments are given, remove the .backups folder in the current dir.
#   If -r is given, remove ALL .backups folders under the specified target_dir.
#   If target_dir isn't provided, use "." (the current directory).
##############################################################################
##############################################################################
# clean_bak - Remove backup directories
#
# Removes .backups directories either in the specified directory or
# recursively throughout a directory tree.
#
# Usage:
#   clean_bak              # Remove .backups in current directory
#   clean_bak path/to/dir  # Remove .backups in specified directory
#   clean_bak -r .         # Remove all .backups recursively
#
# Options:
#   -r  Remove all .backups directories recursively
#   -h  Show this help message
#
# Args:
#   target_dir - Directory to clean (default: current directory)
##############################################################################
function clean_bak() {
    # Parse options using zparseopts
    local -A opts
    zparseopts -D -A opts -- r h -help || {
        echo "Usage: clean_bak [-r] [target_dir]"
        return 1
    }

    # Check for help flag
    if (( ${+opts[-h]} )) || (( ${+opts[--help]} )); then
        echo "Usage: clean_bak [-r] [target_dir]"
        echo ""
        echo "Options:"
        echo "  -r           Remove all .backups dirs recursively"
        echo "  -h, --help   Show this help message"
        echo ""
        echo "Args:"
        echo "  target_dir   Directory to clean (default: current directory)"
        return 0
    fi

    # Determine if recursive mode is enabled
    local recursive=false
    (( ${+opts[-r]} )) && recursive=true

    # Get target directory (first remaining argument, or default to current dir)
    local target="${1:-.}"

    # Validate that target is a directory
    if [[ ! -d "$target" ]]; then
        echo "Error: '$target' is not a directory."
        return 1
    fi

    if [[ "$recursive" == true ]]; then
        # Remove all .backups folders inside target, at any depth
        local backup_dir="$target/.backups"
        if [[ -d "$backup_dir" ]]; then
            echo "Removing '$backup_dir'..."
            rm -rf "$backup_dir"
        else
            echo "No .backups found in '$target'."
        fi
        # Also remove all nested .backups directories
        # Use array to avoid subshell issues with pipes
        local -a nested_dirs
        nested_dirs=("${(@f)$(find "$target" -mindepth 2 -type d -name ".backups" 2>/dev/null)}")
        for dir in "${nested_dirs[@]}"; do
            [[ -n "$dir" ]] && echo "Removing '$dir'..." && rm -rf "$dir"
        done
    else
        # Remove .backups only in the target directory itself
        local backup_dir="$target/.backups"
        if [[ -d "$backup_dir" ]]; then
            echo "Removing '$backup_dir'..."
            rm -rf "$backup_dir"
        else
            echo "No .backups found in '$target'."
        fi
    fi
}

##############################################################################
# add_host - Add entry to /etc/hosts
#
# Adds a new IP-to-hostname mapping to a hosts file with duplicate checking.
# Requires sudo privileges when modifying /etc/hosts.
#
# Args:
#   $1 - IP address (e.g., 192.168.1.10)
#   $2 - Hostname (e.g., myserver.local)
#   $3 - (Optional) Hosts file path (default: /etc/hosts)
#
# Returns:
#   0 on success, 1 on error
#
# Examples:
#   add_host 192.168.1.10 myserver.local
#   add_host 127.0.0.1 dev.example.com
#   add_host 192.168.1.10 myserver.local /tmp/hosts  # For testing
##############################################################################
function add_host() {
    local ip="$1"
    local hostname="$2"
    local hosts_file="${3:-/etc/hosts}"

    if [[ -z "$ip" || -z "$hostname" ]]; then
        echo "Usage: add_host <IP> <hostname> [hosts_file]"
        return 1
    fi

    # Validate IP address format (basic check)
    if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Error: Invalid IP address format '$ip'"
        return 1
    fi

    # Check if the hostname already exists in hosts file
    # Use mixed quoting to prevent zsh from interpreting [[:space:]] as array subscript
    if grep -q '[[:space:]]'"$hostname"'[[:space:]]*$' "$hosts_file"; then
        echo "Error: Hostname '$hostname' already exists in $hosts_file."
        return 1
    fi

    # Append new entry to hosts file
    # Use sudo only for /etc/hosts, direct write for other files
    if [[ "$hosts_file" == "/etc/hosts" ]]; then
        echo "$ip    $hostname" | sudo tee -a "$hosts_file" > /dev/null
    else
        echo "$ip    $hostname" >> "$hosts_file"
    fi
    echo "Added: $ip -> $hostname"
}

##############################################################################
# remove_host - Remove entry from /etc/hosts
#
# Removes an IP-to-hostname mapping from a hosts file using exact hostname
# matching to prevent accidentally removing similar hostnames.
# Requires sudo privileges when modifying /etc/hosts.
#
# Args:
#   $1 - Hostname to remove (e.g., myserver.local)
#   $2 - (Optional) Hosts file path (default: /etc/hosts)
#
# Returns:
#   0 on success, 1 on error
#
# Examples:
#   remove_host myserver.local
#   remove_host dev.example.com
#   remove_host myserver.local /tmp/hosts  # For testing
##############################################################################
function remove_host() {
    local hostname="$1"
    local hosts_file="${2:-/etc/hosts}"

    if [[ -z "$hostname" ]]; then
        echo "Usage: remove_host <hostname> [hosts_file]"
        return 1
    fi

    # Check if the hostname exists in hosts file (match exact hostname only)
    # Use mixed quoting to prevent zsh from interpreting [[:space:]] as array subscript
    if ! grep -q '^[0-9.]\+[[:space:]]\+'"$hostname"'[[:space:]]*$' "$hosts_file"; then
        echo "Error: Hostname '$hostname' not found in $hosts_file."
        return 1
    fi

    # Determine correct sed syntax for in-place editing
    # Match: IP address + whitespace + exact hostname + optional whitespace + end of line
    # Use mixed quoting to prevent zsh from interpreting [[:space:]] as array subscript
    # Use -E for extended regex (required on macOS where \+ is literal in basic regex)
    # Use sudo only for /etc/hosts
    if [[ "$hosts_file" == "/etc/hosts" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sudo sed -i '' -E '/^[0-9.]+[[:space:]]+'"$hostname"'[[:space:]]*$/d' "$hosts_file"
        else
            sudo sed -i -E '/^[0-9.]+[[:space:]]+'"$hostname"'[[:space:]]*$/d' "$hosts_file"
        fi
    else
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -E '/^[0-9.]+[[:space:]]+'"$hostname"'[[:space:]]*$/d' "$hosts_file"
        else
            sed -i -E '/^[0-9.]+[[:space:]]+'"$hostname"'[[:space:]]*$/d' "$hosts_file"
        fi
    fi

    echo "Removed: $hostname from $hosts_file"
}

##############################################################################
# mkd - Make directory and change into it
#
# Creates a directory (and any parent directories) and immediately changes
# into it. Useful for quickly setting up and entering new directory structures.
#
# Args:
#   $@ - Directory path(s) to create
#
# Examples:
#   mkd ~/projects/new-project
#   mkd deeply/nested/directory/structure
##############################################################################
function mkd() {
	mkdir -p "$@" && cd "${@[-1]}"
}

##############################################################################
# rmd - Remove empty directory and list parent
#
# Removes an empty directory and then lists the contents of the parent
# directory. Only works on empty directories (use rm -rf for non-empty).
#
# Args:
#   $@ - Directory path(s) to remove
#
# Examples:
#   rmd old-empty-folder
##############################################################################
function rmd() {
    local target="${1:-.}"
    
    # If removing current directory (. or no args), cd to parent first
    if [[ "$target" == "." || -z "$1" ]]; then
        local current_dir="$PWD"
        builtin cd .. || return 1
        rmdir "$current_dir" || { builtin cd "$current_dir"; return 1; }
        if command -v lsd &> /dev/null; then
            lsd
        fi
    else
        # Just remove the specified directory
        if ! command -v lsd &> /dev/null; then
            rmdir "$@"
        else
            rmdir "$@" && lsd
        fi
    fi
}

##############################################################################
# fs - File/directory size
#
# Displays the size of a file or the total size of a directory in a
# human-readable format. If no arguments are provided, shows sizes for
# all files and directories (including hidden) in the current directory.
#
# Args:
#   $@ - Optional file or directory paths (defaults to all items in current dir)
#
# Examples:
#   fs                    # Size of everything in current directory
#   fs ~/Documents        # Size of Documents directory
#   fs file1.txt file2.txt
##############################################################################
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* *;
	fi;
}

##############################################################################
# o - Open in default application
#
# Opens files or directories in their default application (macOS Finder if
# directory). If no arguments provided, opens the current directory.
#
# Args:
#   $@ - Optional file or directory paths (defaults to current directory)
#
# Examples:
#   o                     # Opens current directory in Finder
#   o ~/Documents         # Opens Documents in Finder
#   o file.pdf            # Opens PDF in default viewer
##############################################################################
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

##############################################################################
# colormap - Display 256-color palette
#
# Displays all 256 colors available in the terminal with their corresponding
# color codes. Useful for debugging color issues and choosing colors for
# terminal customization.
#
# Usage:
#   colormap
#
# Output:
#   Displays a grid of colored blocks with numbers 000-255
##############################################################################
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

##############################################################################
# shist - Show history with timestamps
#
# Displays the Zsh command history along with timestamps for each entry.
#
# Args:
#   $1 - Optional number of recent entries to show (default: all)
#
# Returns:
#   0 on success, 1 on error
#
# Examples:
#   shist            # Show entire history with timestamps
#   shist 20         # Show last 20 commands with timestamps
##############################################################################
function shist() {
    # Declare associative array for options
    local -A opts
    local num_entries=""

    # Parse options using zparseopts
    zparseopts -D -A opts -- n: h -help || {
        echo "Usage: shist [-n <number>]"
        return 1
    }

    # Check for help flag
    if (( ${+opts[-h]} )) || (( ${+opts[--help]} )); then
        echo "Usage: shist [-n <number>]"
        echo ""
        echo "Options:"
        echo "  -n <number>   Limit to last <number> entries"
        echo "  -h, --help    Show this help message"
        return 0
    fi

    # Extract the -n value if provided
    if (( ${+opts[-n]} )); then
        num_entries="${opts[-n]}"
    fi

    # Show history with timestamps using fc -lt (works on all systems)
    if [[ -n "$num_entries" ]]; then
        fc -lt '%Y-%m-%d %H:%M:%S' -"$num_entries" -1
    else
        fc -lt '%Y-%m-%d %H:%M:%S' 1 -1
    fi
}

##############################################################################
# search_hist - Search history for keyword
#
# Search the Zsh command history for a specific keyword and displayed with
# timestamps.
#
# Args:
#   $1 - Optional keyword to search for
#   $2 - Optional number of entries to show (default: all)
#
# Returns:
#   0 on success, 1 on error
#
# Examples:
#   search_hist            # Show usage info
#   search_hist -h       # Show usage info
#   search_hist "keyword"  # Show history entries containing "keyword"
#   search_hist keyword     # Show history entries containing "keyword"
#   search_hist -n 5 keyword # Show last 5 history entries containing "keyword"
##############################################################################
function search_hist() {
    # Declare associative array for options
    local -A opts
    local num_entries=""

    # Parse options using zparseopts
    zparseopts -D -A opts -- n: h -help || {
        echo "Usage: search_hist [-n <number>] <keyword>"
        return 1
    }

    # Check for help flag
    if (( ${+opts[-h]} )) || (( ${+opts[--help]} )); then
        echo "Usage: search_hist [-n <number>] <keyword>"
        echo ""
        echo "Options:"
        echo "  -n <number>   Limit to last <number> entries"
        echo "  -h, --help    Show this help message"
        return 0
    fi

    # Extract the -n value if provided
    if (( ${+opts[-n]} )); then
        num_entries="${opts[-n]}"
    fi

    # Get the keyword (last remaining argument after zparseopts processed flags)
    local keyword="${@[-1]}"
    
    if [[ -z "$keyword" ]]; then
        echo "Error: Missing required keyword argument."
        echo "Usage: search_hist [-n <number>] <keyword>"
        return 1
    fi

    # Validate num_entries if provided
    if [[ -n "$num_entries" && ! "$num_entries" =~ ^[0-9]+$ ]]; then
        echo "Error: -n argument must be a number."
        return 1
    fi

    # Use fc to get history, then grep for keyword
    # fc -l shows history without timestamps, just number and command
    # Use -e to handle keywords that start with dashes
    if [[ -n "$num_entries" ]]; then
        fc -lt '%Y-%m-%d %H:%M:%S' 1 -1 | grep -i -e "$keyword" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | tail -n "$num_entries"
    else
        fc -lt '%Y-%m-%d %H:%M:%S' 1 -1 | grep -i -e "$keyword" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//'
    fi
}