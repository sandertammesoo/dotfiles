#!/usr/bin/env zsh

# Check if Homebrew is installed
require_brew || return 1

# Install sketchybar if not installed
brew_install_if_missing "sketchybar" "FelixKratz/formulae/sketchybar" || return 1

# Install font-sketchybar-app-font if not installed
brew_install_if_missing "font-sketchybar-app-font" "font-sketchybar-app-font" || return 1

# Stop sketchybar service if it's running using sketchybar command
log_user "Checking if sketchybar service is running..."
run_cmd="pgrep -x sketchybar"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
echo "$output" | output_stream VERBOSE
if [ $exit_code -eq 0 ]; then
    log_user "sketchybar service is currently running. Stopping it first..."
    run_cmd="brew services stop sketchybar"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream
        log_success "sketchybar service stopped successfully."
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to stop sketchybar service."
        return 1
    fi
else
    log_skip "sketchybar service is not running. Proceeding..."
fi

# Try and update sketchybar to the latest version
log_user "Updating sketchybar to the latest version..."
run_cmd="brew upgrade FelixKratz/formulae/sketchybar"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
# Filter output but maintain original exit code
if [ $exit_code -eq 0 ]; then
    echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
    log_success "sketchybar update successful"
else
    echo "$output" | output_stream FATAL
    log_fatal "sketchybar update failed"
    return 1
fi

# Clone and build sketchybar-app-font
log_user "Setting up sketchybar app font..."
TEMP_DIR=$(mktemp -d)
run_cmd="git clone https://github.com/kvndrsslr/sketchybar-app-font.git \"$TEMP_DIR\""
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "$output" | output_stream FATAL
    log_fatal "Failed to clone sketchybar-app-font repository"
    rm -rf "$TEMP_DIR"
    return 1
else
    echo "$output" | output_stream VERBOSE
    cd "$TEMP_DIR" || { rm -rf "$TEMP_DIR"; return 1; }
    
    # Install pnpm if not available
    log_verbose "Checking if pnpm is installed..."
    run_cmd="command -v pnpm"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?  # Capture exit status
    echo "Output: $output" | output_stream VERBOSE
    if [ $exit_code -ne 0 ]; then
        log_info "Installing pnpm..."

        # log_verbose "Checking if npm is installed..."
        # run_cmd="command -v npm"
        # log_verbose "Running command: $run_cmd"
        # output=$(eval "$run_cmd" 2>&1)
        # exit_code=$?  # Capture exit status
        # if [ $exit_code -ne 0 ]; then
        #     echo "$output" | output_stream FATAL
        #     log_fatal "npm is not installed. Please install Node.js which includes npm."
        #     # Cleanup
        #     cd - > /dev/null 2>&1 || true  # Don't fail if cd - doesn't work
        #     rm -rf "$TEMP_DIR"
        #     return 1
        # else
        #     echo "Output: $output" | output_stream VERBOSE
        # fi

        run_cmd="brew install pnpm"
        log_verbose "Running command: $run_cmd"
        output=$(eval "$run_cmd" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo "$output" | output_stream VERBOSE
            log_success "pnpm installed successfully!"
        else
            echo "$output" | output_stream FATAL
            log_fatal "pnpm installation failed."
            # Cleanup
            cd - > /dev/null 2>&1 || true  # Don't fail if cd - doesn't work
            rm -rf "$TEMP_DIR"
            return 1
        fi
    fi
    
    # Build and install
    TARGET_SCRIPT="$XDG_CONFIG_HOME/sketchybar/plugins/icon_map_fn.sh"
    run_cmd="pnpm install && pnpm run build:install \"$TARGET_SCRIPT\""
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream VERBOSE
        # build:install prepends a newline to the START-OF-ICON-MAP marker each run,
        # causing blank lines to accumulate. Squash multiple consecutive blank lines to one.
        local cleaned
        cleaned=$(awk '/^$/{blank++; if(blank<=1)print; next} {blank=0; print}' "$TARGET_SCRIPT")
        printf '%s\n' "$cleaned" > "$TARGET_SCRIPT"
        log_success "sketchybar app font built and installed successfully!"
        log_info "Installed sketchybar app font to $TARGET_SCRIPT"
        log_info "You can use this font in your sketchybar configuration to display app icons in your bar."
        log_info "Example usage in sketchybar config: sketchybar --set \$NAME icon.font=\"$TARGET_SCRIPT:Regular:16.0\""
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to build and install sketchybar app font"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Cleanup
    cd - > /dev/null 2>&1 || true  # Don't fail if cd - doesn't work
    rm -rf "$TEMP_DIR"
fi

# Start sketchybar service
log_user "Starting sketchybar service..."
run_cmd="brew services start sketchybar"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream VERBOSE
    log_success "Started sketchybar service."
else
    echo "$output" | output_stream FATAL
    log_fatal "Failed to start sketchybar service."
    return 1
fi

log_success "sketchybar installation and configuration complete!"
return 0