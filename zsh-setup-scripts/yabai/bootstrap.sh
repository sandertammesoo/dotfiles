#!/usr/bin/env zsh

# Check if Homebrew is installed
require_brew || return 1

# Homebrew 6.0+ won't load a non-official tap until it's trusted (HOMEBREW_REQUIRE_TAP_TRUST).
brew_trust_tap "asmvik/formulae"

# Install yabai if not installed
brew_install_if_missing "yabai" "yabai" || return 1


# Stop yabai service if it's running using yabai command
log_user "Checking if yabai service is running..."
run_cmd="pgrep -x yabai"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
# echo "Output: $output" | verbose_stream
if [ $exit_code -eq 0 ]; then
    log_user "yabai service is currently running. Stopping it first..."
    run_cmd="yabai --stop-service --verbose"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?  # Capture exit status
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream
        log_success "yabai service stopped successfully."
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to stop yabai service."
        return 1
    fi
else
    echo "Output: $output" | verbose_stream
    log_skip "yabai service is not running. Proceeding..."
fi

# Try and remove old service file because homebrew changes binary path and old service file will break if it exists
log_user "Removing old yabai service file if it exists..."
run_cmd="yabai --uninstall-service --verbose"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream
    log_success "Old yabai service file removed successfully."
else
    echo "$output" | output_stream ERROR
    log_warn "Failed to remove old yabai service file. It may not exist, Double checking..."
    PLIST_FILE="$HOME/Library/LaunchAgents/com.asmvik.yabai.plist"
    if [ -f "$PLIST_FILE" ]; then
        log_warn "Old yabai service file still exists at $PLIST_FILE. Attempting to remove it..."
        run_cmd="rm \"$PLIST_FILE\""
        log_verbose "Running command: $run_cmd"
        output=$(eval "$run_cmd" 2>&1)
        exit_code=$?  # Capture exit status
        if [ $exit_code -eq 0 ]; then
            echo "$output" | output_stream
            log_success "Old yabai service file removed successfully."
        else
            echo "$output" | output_stream FATAL
            log_fatal "Failed to remove old yabai service file. Please check the error message above and remove the file manually before proceeding."
            return 1
        fi
    else
        log_success "Old yabai service file does not exist. Proceeding..."
    fi
fi

# Try and update yabai to the latest version
log_user "Updating yabai to the latest version..."
# log_skip "Skipping upgrade to 7.1.17 to avoid installing a broken version."
# log_warn "See: https://github.com/asmvik/yabai/issues/2747"
#
# HEAD builds: macOS 26.6.2 (25G83) changed the Dock so the scripting-addition payload shipped
# with v7.1.25 (osax 2.1.29) no longer finds addSpace; `space --create` then silently does
# nothing. The fix (osax 2.1.30) is only on master, so yabai may be installed as a HEAD keg
# (`brew unlink yabai && brew install asmvik/formulae/yabai --HEAD`). Plain `brew upgrade`
# ignores HEAD kegs; --fetch-HEAD rebuilds when master moved. Once a tagged release contains
# the fix, go back with: brew unlink yabai && brew install asmvik/formulae/yabai
# Reference: https://github.com/asmvik/yabai/issues/2799 and /issues/2821
#
# Any rebuild changes the binary's code signature. The sudoers hash is regenerated below, but the
# macOS Accessibility grant is NOT — see the post-start check at the end of this script.
YABAI_HASH_BEFORE=$(shasum -a 256 "$(realpath "$(command -v yabai)")" | awk '{print $1}')
if [[ "$(realpath "$(command -v yabai)")" == */Cellar/yabai/HEAD-* ]]; then
    log_info "yabai is a HEAD build (master); upgrading with --fetch-HEAD."
    run_cmd="brew upgrade --fetch-HEAD yabai"
else
    run_cmd="brew upgrade yabai"
fi
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    # Filter output but maintain original exit code
    echo "Output: $output" | verbose_stream
    echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
    log_success "yabai update successful"
else
    echo "$output" | output_stream FATAL
    log_fatal "yabai update failed"
fi

# Get the hash of yabai
YABAI_HASH=$(shasum -a 256 $(which yabai) | awk '{print $1}')
if [[ "$YABAI_HASH" != "$YABAI_HASH_BEFORE" ]]; then
    log_warn "yabai binary changed during upgrade. Its Accessibility grant is tied to the old signature;"
    log_warn "re-add $(command -v yabai) in System Settings → Privacy & Security → Accessibility or yabai will abort on start."
fi

# Check if sudoers file already contains the correct line
log_user "Checking if sudoers file for yabai already contains the correct line..."
SUDOERS_FILE="/private/etc/sudoers.d/yabai"
UPDATE_FILE=false
if [ -f "$SUDOERS_FILE" ]; then
    run_cmd="sudo grep -q \"$YABAI_HASH\" \"$SUDOERS_FILE\""
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?  # Capture exit status
    echo "Output: $output" | verbose_stream
    if [ $exit_code -eq 0 ]; then
        log_success "Sudoers file for yabai already configured."
    else
        log_warn "Sudoers file for yabai exists but does not contain the correct hash. It will be updated."
        # Backup existing sudoers file if it exists
        log_info "Backing up existing sudoers file..."
        run_cmd="sudo cp \"$SUDOERS_FILE\" \"${SUDOERS_FILE}.bak_$(date +%Y%m%d%H%M%S)\""
        log_verbose "Running command: $run_cmd"
        output=$(eval "$run_cmd" 2>&1)
        exit_code=$?  # Capture exit status
        if [ $exit_code -eq 0 ]; then
            echo "Output: $output" | output_stream VERBOSE
            log_success "Sudoers file backed up successfully."
        else
            echo "$output" | output_stream FATAL
            log_fatal "Failed to back up existing sudoers file."
            return 1
        fi
        UPDATE_FILE=true
    fi
else
    log_user "Sudoers file for yabai not found. It will be created."
    UPDATE_FILE=true
fi

# Create sudoers file for yabai
if [ "$UPDATE_FILE" = true ]; then
    log_user "Setting up sudoers file for yabai..."
    log_info "Creating new sudoers file at $SUDOERS_FILE"
    sudo touch $SUDOERS_FILE

    # Create or update the sudoers file
    LINE_TO_ADD="$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa"
    log_debug "Sudoers line to add: $LINE_TO_ADD"
    if echo "$LINE_TO_ADD" | sudo tee $SUDOERS_FILE; then  
        # Validate the sudoers file content
        if sudo grep -q "$LINE_TO_ADD" $SUDOERS_FILE; then
            log_success "Sudoers file content verified successfully."
        else
            log_fatal "Sudoers file content verification failed."
            return 1
        fi
        log_success "Sudoers file created/updated successfully."
    else
        log_fatal "Failed to create/update sudoers file."
        return 1
    fi

    # Set correct permissions for sudoers file
    if sudo chmod 440 $SUDOERS_FILE; then
        log_success "Sudoers file permissions set to 440."
    else
        log_fatal "Failed to set permissions for sudoers file."
        return 1
    fi

    # Clear backups
    log_info "Clearing old backup sudoers files..."
    run_cmd="sudo find /private/etc/sudoers.d/ -name \"yabai.bak_*\" -type f -delete"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?  # Capture exit status
    if [ $exit_code -eq 0 ]; then
        echo "Output: $output" | output_stream VERBOSE
        log_success "Old backup sudoers files cleared successfully."
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to clear old backup sudoers files."
        return 1
    fi
fi

# Try and load the scripting addition
# No --verbose here: the sudoers rule written above is `yabai --load-sa` with exact arguments,
# so any extra flag falls outside NOPASSWD and sudo prompts for a password instead.
log_user "Loading yabai scripting addition..."
run_cmd="sudo yabai --load-sa"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream
    log_success "yabai scripting addition loaded successfully."
else
    echo "$output" | output_stream ERROR
    log_warn "Initial --load-sa attempt failed. Checking for known issues..."

    # Check for PAC ABI version mismatch (Apple Silicon only).
    # Newer Clang builds the loader binary with PAC ABI v1 (caps 0x81), but system processes
    # like Dock.app use PAC ABI v0 (caps 0x80). The kernel blocks injection of v1 binaries into
    # v0 processes, causing --load-sa to fail. The fix is to patch the Fat/Mach-O headers from
    # 0x81 → 0x80 and re-sign. Safe because there are no assembly-level differences between the
    # two ABI versions — it is purely a header declaration.
    # Note: The loader binary only exists after the first (failed) --load-sa attempt copies the
    # osax into /Library/ScriptingAdditions/, which is why we patch reactively here.
    # Reference: https://github.com/asmvik/yabai/issues/2686
    LOADER_PATH="/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader"
    if [[ "$(uname -m)" == "arm64" ]] && [[ -f "$LOADER_PATH" ]]; then
        log_debug "Checking for PAC ABI v1 mismatch in loader binary..."
        read PAC_ARCH_IDX PAC_OFFSET <<< $(otool -f "$LOADER_PATH" 2>/dev/null \
            | awk '/architecture/{i=$2} /capabilities 0x81/{f=1} f&&/offset/{print i, $2; exit}')

        if [[ -n "$PAC_OFFSET" ]]; then
            log_warn "PAC ABI v1 (caps 0x81) detected in loader binary. Patching to v0 (caps 0x80)..."
            log_debug "Loader: arch index=$PAC_ARCH_IDX, slice offset=$PAC_OFFSET"

            PAC_FAT_SEEK=$((8 + PAC_ARCH_IDX*20 + 4))
            PAC_MACH_SEEK=$((PAC_OFFSET + 11))
            printf '\x80' | sudo dd of="$LOADER_PATH" bs=1 seek=$PAC_FAT_SEEK count=1 conv=notrunc 2>/dev/null
            printf '\x80' | sudo dd of="$LOADER_PATH" bs=1 seek=$PAC_MACH_SEEK count=1 conv=notrunc 2>/dev/null

            log_info "Re-signing patched loader binary..."
            sudo codesign -f -s - "$LOADER_PATH" 2>/dev/null
            log_success "Loader binary patched and re-signed. Retrying --load-sa..."

            run_cmd="sudo yabai --load-sa"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            if [ $exit_code -eq 0 ]; then
                echo "$output" | output_stream
                log_success "yabai scripting addition loaded successfully after PAC ABI patch."
            else
                echo "$output" | output_stream ERROR
                log_warn "Still failed after PAC ABI patch."
            fi
        else
            log_debug "No PAC ABI v1 mismatch detected in loader binary."
        fi
    fi

    if [ $exit_code -ne 0 ]; then
        # On macOS 26+, --load-sa exits 1 even when the SA loads successfully.
        # The SA notification is still delivered and yabai works normally.
        # Reference: https://github.com/asmvik/yabai/issues/2764
        # Also on macOS 26 Tahoe, --load-sa may fail with "could not locate Dock.app pid"
        # even when yabai is otherwise functional. Treat both as non-fatal on macOS 26+.
        MACOS_MAJOR=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)
        OSAX_PATH="/Library/ScriptingAdditions/yabai.osax"
        if [[ "$MACOS_MAJOR" -ge 26 ]] && [[ -d "$OSAX_PATH" ]] && \
           ([[ -z "$output" ]] || [[ "$output" == *"could not locate Dock.app pid"* ]]); then
            if [[ -z "$output" ]]; then
                log_warn "Known macOS 26+ issue: --load-sa exits 1 even when the scripting addition loads successfully."
                log_warn "See: https://github.com/asmvik/yabai/issues/2764"
            else
                log_warn "--load-sa reported 'could not locate Dock.app pid' but osax is present at $OSAX_PATH."
                log_warn "This may be a transient state (Dock.app not yet reachable). Continuing with service start."
            fi
            log_success "osax is present at $OSAX_PATH — treating as success and continuing."
            exit_code=0
        else
            log_fatal "Failed to load yabai scripting addition."

            log_debug "Checking if the failure is due to SIP being enabled..."
            run_cmd="csrutil status"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            echo "Output: $output" | output_stream VERBOSE
            if [[ "$output" == *"System Integrity Protection status: enabled"* ]]; then
                log_fatal "SIP is enabled, which is likely causing the failure to load the scripting addition. Please disable SIP and try again."
            else
                log_fatal "SIP does not appear to be enabled. Please investigate the error message above to determine the cause of the failure to load the scripting addition."
            fi

            log_debug "Checking boot-args for amfi_get_out_of_my_way=1..."
            run_cmd="nvram -p | grep boot-args"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            if [ $exit_code -eq 0 ]; then
                echo "Output: $output" | output_stream VERBOSE
            else
                log_warn "Failed to retrieve boot-args value."
            fi

            log_debug "Checking nvram variables..."
            run_cmd="nvram -p"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            if [ $exit_code -eq 0 ]; then
                echo "Output: $output" | output_stream VERBOSE
            else
                log_warn "Failed to retrieve nvram variables."
            fi

            log_debug "Checking sysctl kern.bootargs for amfi_get_out_of_my_way=1..."
            run_cmd="sysctl kern.bootargs"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            if [ $exit_code -eq 0 ]; then
                echo "Output: $output" | output_stream VERBOSE
            else
                log_warn "Failed to retrieve kern.bootargs value."
            fi

            log_debug "Getting system information for further debugging..."
            run_cmd="system_profiler SPHardwareDataType SPSoftwareDataType"
            log_verbose "Running command: $run_cmd"
            output=$(eval "$run_cmd" 2>&1)
            exit_code=$?  # Capture exit status
            echo "Output: $output" | output_stream VERBOSE
            if [ $exit_code -ne 0 ]; then
                log_warn "Failed to retrieve system information."
            fi

            return 1
        fi
    fi
fi

log_debug "Configuring macOS system settings for optimal yabai performance..."
# Disable macOS window animations for better performance with yabai
defaults write com.apple.finder DisableAllAnimations -bool true
log_debug "Restarting Finder to apply animation settings..."
killall Finder # or logout and login

# to reset system defaults, delete the key instead
# defaults delete com.apple.finder DisableAllAnimations

# Try and start yabai service
log_user "Starting yabai service..."
run_cmd="yabai --start-service --verbose"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream VERBOSE
    log_success "Started yabai service."
else
    echo "$output" | output_stream FATAL
    log_fatal "Failed to start yabai service."
    return 1
fi

# Post-start check 1: is yabai actually running? A rebuilt binary (HEAD build, brew upgrade) loses
# its Accessibility grant because macOS ties the grant to the code signature. yabai then exits at
# once with "could not access accessibility features! abort.." while --start-service still returns 0.
log_user "Waiting for yabai to answer..."
for _ in {1..10}; do
    yabai -m query --displays &>/dev/null && break
    sleep 0.5
done
if ! yabai -m query --displays &>/dev/null; then
    YABAI_ERR_LOG="/tmp/yabai_${USER}.err.log"
    if ! pgrep -x yabai &>/dev/null && grep -q "could not access accessibility features" "$YABAI_ERR_LOG" 2>/dev/null; then
        log_error "yabai exited: the current binary has no Accessibility permission."
        log_error "System Settings → Privacy & Security → Accessibility: remove yabai, add $(command -v yabai), then run: yabai --start-service"
    else
        log_error "yabai did not answer within 5 seconds. See $YABAI_ERR_LOG"
    fi
    return 1
fi

# Post-start check 2: does the scripting addition actually work? --load-sa can report success (or
# the tolerated exit 1 above) while single payload functions failed to resolve against this Dock
# build. That shows up only as SA commands doing nothing: exit 0, no output, no new space.
# Seen on macOS 26.6.2 (25G83) with osax 2.1.29 — https://github.com/asmvik/yabai/issues/2821
log_user "Verifying scripting addition (create + destroy a space)..."
SA_SPACES_BEFORE=$(yabai -m query --spaces | jq -c '[.[].id]')
yabai -m space --create &>/dev/null
SA_NEW_INDEX=$(yabai -m query --spaces | jq -r --argjson before "$SA_SPACES_BEFORE" \
    '.[] | select(.id as $id | $before | index($id) | not) | .index' | head -n 1)
if [[ -n "$SA_NEW_INDEX" ]]; then
    yabai -m space --destroy "$SA_NEW_INDEX" &>/dev/null
    log_success "Scripting addition works: space create/destroy verified."
else
    log_error "Scripting addition is injected but 'space --create' did nothing: the payload's Dock patterns do not match this macOS build."
    log_error "Fix: brew unlink yabai && brew install asmvik/formulae/yabai --HEAD, rerun this bootstrap, then: killall Dock"
    log_error "See: https://github.com/asmvik/yabai/issues/2821"
fi

log_success "Yabai installation and configuration complete!"
return 0