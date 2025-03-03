#!/bin/zsh

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
        mkdir -p "$backup_path"
        # Copy contents (.* for hidden files if needed)
        cp -r "$target"/. "$backup_path"
    else
        cp "$target" "$backup_path"
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

    # Check if input ends with ".bak<number>"
    if [[ "$input" =~ \.bak[0-9]+$ && -e "$input" ]]; then
        # The user provided an actual backup path => use it directly
        _restore_bak_file "$input"
    else
        # The user provided what looks like an original filename => find latest backup
        local dir name backups_dir
        dir="$(dirname "$input")"
        name="$(basename "$input")"
        backups_dir="$dir/.backups"

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
    fi
}

##############################################################################
# Restore a file from a backup, printing only relative paths
##############################################################################
function _restore_bak_file() {
    local backup="$1"

    if [[ -z "$backup" || ! -e "$backup" ]]; then
        echo "Usage: _restore_bak_file <backup_file_or_folder>"
        return 1
    fi

    # Clean up possible newlines or ANSI codes
    backup="$(echo "$backup" | tr -d '\n' | sed 's/\x1B\[[0-9;]*m//g')"

    # Break down the backup path
    local backup_dir
    backup_dir="$(dirname "$backup")"

    local backup_name
    backup_name="$(basename "$backup")"

    local original_name="${backup_name%.bak*}"

    # Force built-in cd/pwd to avoid alias issues
    local original_dir
    original_dir="$(
        builtin cd "$backup_dir/.." \
        && builtin pwd
    )"

    local original_path="$original_dir/$original_name"

    # Make sure the target directory exists
    mkdir -p "$(dirname "$original_path")"

    # If the original item (file OR folder) exists, back it up
    if [[ -e "$original_path" ]]; then
        local prev_bak
        prev_bak="$(new_bak "$original_path" | awk '{print $NF}')"
        echo "Created new backup from '$(to_relative "$original_path")': $(to_relative "$prev_bak")"

        if [[ -d "$original_path" ]]; then
            # Remove everything inside but leave the folder itself
            echo "Cleaning out '$(to_relative "$original_path")' before restore..."
            # Safely remove all contents but leave the folder
            find "$original_path" -mindepth 1 -delete 2>/dev/null
        else
            # If it was just a file, remove it
            echo "Removing file '$(to_relative "$original_path")' before restore..."
            rm -f "$original_path"
        fi
    else
        echo "Warning: The original item '$(to_relative "$original_path")' does not exist. Restoring anyway."
    fi

    # For the restore, if this backup is a directory => cp -r; else cp
    if [[ -d "$backup" ]]; then
        mkdir -p "$original_path"       # Ensure the original folder exists
        cp -r "$backup"/. "$original_path"
    else
        cp "$backup" "$original_path"
    fi

    echo "Restored '$(to_relative "$original_path")' from '$(to_relative "$backup")'"
}

##############################################################################
# clean_bak [ -r ] [ target_dir ]
#   If no arguments are given, remove the .backups folder in the current dir.
#   If -r is given, remove ALL .backups folders under the specified target_dir.
#   If target_dir isn't provided, use "." (the current directory).
##############################################################################
function clean_bak() {
    local usage="Usage: clean_bak [ -r ] [ target_dir ]
  -r           Remove all .backups dirs recursively below target_dir
  target_dir   Directory to clean (default: current directory)"

    local recursive=false
    local target="."

    # Parse flags/args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r)
                recursive=true
                shift
                ;;
            -h|--help)
                echo "$usage"
                return 0
                ;;
            *)
                # Assume it's the target directory
                target="$1"
                shift
                ;;
        esac
    done

    # Validate that target is a directory
    if [[ ! -d "$target" ]]; then
        echo "Error: '$target' is not a directory."
        echo "$usage"
        return 1
    fi

    if [[ "$recursive" == true ]]; then
        # Remove all .backups folders inside target, at any depth
        echo "Removing all .backups directories under '$target'..."
        find "$target" -type d -name ".backups" -exec rm -rf {} + 2>/dev/null
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

# Function to add new host entries to /etc/hosts
function add_host() {
    local ip="$1"
    local hostname="$2"

    if [[ -z "$ip" || -z "$hostname" ]]; then
        echo "Usage: add_host <IP> <hostname>"
        return 1
    fi

    # Check if the hostname already exists in /etc/hosts
    if grep -q "$hostname" /etc/hosts; then
        echo "Error: Hostname '$hostname' already exists in /etc/hosts."
        return 1
    fi

    # Append new entry to /etc/hosts
    echo "$ip    $hostname" | sudo tee -a /etc/hosts > /dev/null
    echo "Added: $ip -> $hostname"
}

# Function to remove a host entry from /etc/hosts
function remove_host() {
    local hostname="$1"

    if [[ -z "$hostname" ]]; then
        echo "Usage: remove_host <hostname>"
        return 1
    fi

    # Check if the hostname exists in /etc/hosts
    if ! grep -q "\s$hostname$" /etc/hosts; then
        echo "Error: Hostname '$hostname' not found in /etc/hosts."
        return 1
    fi

    # Determine correct sed syntax for in-place editing
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo sed -i '' "/[[:space:]]$hostname$/d" /etc/hosts
    else
        sudo sed -i "/[[:space:]]$hostname$/d" /etc/hosts
    fi

    echo "Removed: $hostname from /etc/hosts"
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Remove directory
function rmd() {
	rmdir "$@" && lsd;
}

# Determine size of a file or total size of a directory
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

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# Colormap
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}




#########
# TEST  #
# #######

##############################################################################
# test_backup_helper_functions
# Demonstrates basic usage of new_bak, restore_bak, and clean_bak.
##############################################################################
function test_backup_helper_functions_1 () {

    # Store original working directory so we can return later
    local original_wd="$(pwd)"

    # Exit immediately if any command fails (optional)
    set -e

    # 1) Create a test environment
    echo "=== Setting up test environment ==="
    rm -rf /tmp/test_backup_scenario 2>/dev/null || true
    mkdir -p /tmp/test_backup_scenario
    cd /tmp/test_backup_scenario

    # Create a sample file
    echo "Hello world" > file1.txt
    echo "=== Created /tmp/test_backup_scenario/file1.txt ==="
    cat file1.txt
    echo

    # 2) Demonstrate new_bak on a file
    echo "=== Creating a backup of file1.txt ==="
    new_bak file1.txt
    echo
    tree -a 2>/dev/null || ls -R

    # Make a modification
    echo "Appended content" >> file1.txt
    echo "=== file1.txt after modification ==="
    cat file1.txt
    echo

    # 3) Demonstrate restore_bak on the modified file
    echo "=== Restoring file1.txt from latest backup ==="
    restore_bak file1.txt
    echo "=== file1.txt after restore ==="
    cat file1.txt
    echo
    tree -a 2>/dev/null || ls -R
    echo

    # 4) Demonstrate folder backup
    echo "=== Creating folder and backing it up ==="
    mkdir folderA
    echo "File A1" > folderA/fileA1.txt
    echo "File A2" > folderA/fileA2.txt
    new_bak folderA
    echo
    tree -a 2>/dev/null || ls -R
    echo

    # 5) Modify folder contents, then restore
    echo "=== Modifying folderA, then restoring ==="
    echo "Modified A1" >> folderA/fileA1.txt
    rm folderA/fileA2.txt
    echo "FolderA before restore:"
    tree folderA 2>/dev/null || ls -R folderA
    echo
    restore_bak folderA
    echo "FolderA after restore:"
    tree folderA 2>/dev/null || ls -R folderA
    echo

    # 6) Show how to clean local .backups
    echo "=== Running clean_bak (non-recursive) in current dir ==="
    clean_bak
    echo
    echo "Contents after clean_bak (local only):"
    tree -a 2>/dev/null || ls -R
    echo

    # 7) Create multiple backups in deeper structure for recursive cleaning
    echo "=== Creating deeper structure for recursive cleanup test ==="
    mkdir -p subdir/inner
    touch subdir/inner/secret.txt
    echo "Secret stuff" > subdir/inner/secret.txt
    new_bak subdir/inner
    echo "=== Current structure before recursive clean ==="
    tree -a 2>/dev/null || ls -R
    echo

    # 8) Demonstrate clean_bak -r
    echo "=== Running clean_bak -r in current dir to remove ALL .backups recursively ==="
    clean_bak -r
    echo
    echo "Contents after recursive clean_bak:"
    tree -a 2>/dev/null || ls -R
    echo

    # 9) Return to original directory and clean up test environment
    builtin cd "$original_wd"
    rm -rf /tmp/test_backup_scenario
    echo "Cleaned up /tmp/test_backup_scenario and returned to '$original_wd'."

    echo "=== All done! ==="

}

##############################################################################
# test_backup_helper_functions
# Demonstrates basic usage of new_bak, restore_bak, and clean_bak
# covering these use cases:
#   1) new_bak file1.txt
#   2) new_bak folderA
#   3) new_bak folderA/file1.txt
#   4) restore_bak file1.txt
#   5) restore_bak .backups/file1.txt.bak1
#   6) restore_bak file1.txt.bak1   (when we're inside .backups)
#   7) restore_bak folderA
#   8) restore_bak .backups/folderA.bak1
#   9) restore_bak folderA.bak1     (when we're inside .backups)
#  10) clean_bak
#  11) clean_bak folderA
#  12) clean_bak -r
#  13) clean_bak folderA -r
##############################################################################
function test_backup_helper_functions() {

    local original_wd="$(pwd)"
    # set -e  # Exit on error
    trap 'echo "Something failed in test_backup_helper_functions, but not exiting shell..."' ERR

    # 1) Create a clean test environment
    echo "=== Setting up test environment ==="
    rm -rf /tmp/test_backup_scenario 2>/dev/null || true
    mkdir -p /tmp/test_backup_scenario
    cd /tmp/test_backup_scenario
    echo "Hello world" > file1.txt
    echo "A1" > file2.txt
    mkdir folderA
    echo "folderA-file1" > folderA/file1.txt
    echo "folderA-file2" > folderA/file2.txt

    echo "Initial layout:"
    tree -a 2>/dev/null || ls -R
    cat file1.txt file2.txt
    echo

    #------------------------------------------------------------------------
    # 1) new_bak file1.txt (backup a file)
    #------------------------------------------------------------------------
    echo "=== [1] new_bak file1.txt ==="
    new_bak file1.txt
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 2) new_bak folderA (backup a folder)
    #------------------------------------------------------------------------
    echo "=== [2] new_bak folderA ==="
    new_bak folderA
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 3) new_bak folderA/file1.txt (backup a target file inside folderA)
    #------------------------------------------------------------------------
    echo "=== [3] new_bak folderA/file1.txt ==="
    new_bak folderA/file1.txt
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 4) restore_bak file1.txt (restore a file from latest backup)
    #------------------------------------------------------------------------
    # Make modifications so we can see a difference when restoring
    echo "Modified content in file1.txt" >> file1.txt
    echo "Modified content in folderA/file1.txt" >> folderA/file1.txt

    echo "=== file1.txt and folderA/file1.txt after modification ==="
    cat file1.txt folderA/file1.txt
    echo
    
    echo "=== [4] restore_bak file1.txt ==="
    restore_bak file1.txt
    echo "file1.txt after restore:"
    cat file1.txt
    echo
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 5) restore_bak .backups/file1.txt.bak1 (specific backup of file1.txt)
    #------------------------------------------------------------------------
    echo "=== [5] restore_bak .backups/file1.txt.bak1 ==="
    # We first ensure there's a .backups/file1.txt.bak1
    # Since we might have .bak0, .bak2, etc, let's just do one more backup:
    new_bak file1.txt  # create a second or third backup
    # Now pick .bak1 or .bak2 as needed. We'll guess .bak1:
    restore_bak .backups/file1.txt.bak1
    echo "file1.txt after restoring from .backups/file1.txt.bak1:"
    cat file1.txt
    echo
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 6) restore_bak file1.txt.bak1 while inside .backups
    #------------------------------------------------------------------------
    echo "=== [6] restore_bak file1.txt.bak0 (inside .backups) ==="
    builtin cd .backups
    # We assume there's a file1.txt.bak1 here
    restore_bak file1.txt.bak0
    builtin cd ..
    echo "file1.txt after restoring from .backups/file1.txt.bak0:"
    cat file1.txt
    echo
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 7) restore_bak folderA (restore a folder from latest backup)
    #------------------------------------------------------------------------
    echo "=== [7] restore_bak folderA ==="
    restore_bak folderA
    echo "folderA after restore:"
    tree folderA 2>/dev/null || ls -R folderA
    echo

    #------------------------------------------------------------------------
    # 8) restore_bak .backups/folderA.bak1 (specific backup of folderA)
    #------------------------------------------------------------------------
    echo "=== [8] restore_bak .backups/folderA.bak1 ==="
    # We'll create another backup to ensure we have a .bak1
    new_bak folderA
    restore_bak .backups/folderA.bak1
    echo
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 9) restore_bak folderA.bak1 (while in .backups)
    #------------------------------------------------------------------------
    echo "=== [9] restore_bak folderA.bak1 (inside .backups) ==="
    builtin cd .backups
    restore_bak folderA.bak1
    builtin cd ..
    echo
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 10) clean_bak (remove the .backups in current dir)
    #------------------------------------------------------------------------
    echo "=== [10] clean_bak ==="
    clean_bak
    echo "After clean_bak:"
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # Re-create some .backups to demonstrate the next steps
    new_bak file2.txt
    mkdir folderB
    touch folderB/b1.txt
    new_bak folderB
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 11) clean_bak folderB (remove .backups in target directory)
    #------------------------------------------------------------------------
    echo "=== [11] clean_bak folderB ==="
    clean_bak folderB
    echo "After clean_bak folderB:"
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 12) clean_bak -r (remove .backups recursively in current directory)
    #------------------------------------------------------------------------
    echo "=== [12] clean_bak -r ==="
    # Re-create some nested backups for demonstration
    mkdir -p nested/sub
    echo "nested file" > nested/sub/hello.txt
    new_bak nested/sub
    tree -a 2>/dev/null || ls -R
    echo
    echo "Now cleaning recursively..."
    clean_bak -r
    echo "After clean_bak -r:"
    tree -a 2>/dev/null || ls -R
    echo

    #------------------------------------------------------------------------
    # 13) clean_bak folderA -r (remove .backups recursively in target directory)
    #------------------------------------------------------------------------
    echo "=== [13] clean_bak folderA -r ==="
    # We need a .backups folder under folderA, so let's create something:
    mkdir -p folderA/subdir
    echo "some file" > folderA/subdir/test.txt
    new_bak folderA/subdir
    tree -a 2>/dev/null || ls -R
    echo
    echo "Now cleaning recursively inside folderA..."
    clean_bak folderA -r
    tree -a 2>/dev/null || ls -R
    echo

    # Return to original directory & clean up
    builtin cd "$original_wd"
    rm -rf /tmp/test_backup_scenario
    echo "=== All done! Cleaned up /tmp/test_backup_scenario and returned to '$original_wd'. ==="
}

