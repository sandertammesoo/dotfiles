#!/usr/bin/env zsh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_fatal "Homebrew not installed. Please install it first."
    return 1
fi

# Install sketchybar if not installed
if command -v sketchybar &> /dev/null; then
    log_success "sketchybar is already installed."
else
    log_info "  !   sketchybar not found. Proceeding with installation."
    log_user "Installing sketchybar..."
    output=$(brew install FelixKratz/formulae/sketchybar 2>&1)
    exit_code=$?
    echo "$output" | output_stream
    if [ $exit_code -eq 0 ]; then
        log_success "sketchybar installed successfully!"
    else
        log_fatal "sketchybar installation failed!"
        return 1
    fi
fi
# Verify sketchybar installation
if ! command -v sketchybar &> /dev/null; then
    log_fatal "sketchybar installation verification failed!"
    return 1
fi

# Install font-sketchybar-app-font if not installed
if brew info font-sketchybar-app-font | grep -q "Installed"; then
    log_success "font-sketchybar-app-font is already installed."
else
    log_info "  !   font-sketchybar-app-font not found. Proceeding with installation."
    log_user "Installing font-sketchybar-app-font..."
    output=$(brew install font-sketchybar-app-font 2>&1)
    exit_code=$?
    echo "$output" | output_stream
    if [ $exit_code -eq 0 ]; then
        log_success "font-sketchybar-app-font installed successfully!"
    else
        log_fatal "font-sketchybar-app-font installation failed!"
        return 1
    fi
fi
# Verify font-sketchybar-app-font installation
if ! brew info font-sketchybar-app-font | grep -q "Installed"; then
    log_fatal "font-sketchybar-app-font installation verification failed!"
    return 1
fi

# Stop sketchybar service if it's running using sketchybar command
if brew services list | grep -q '^sketchybar.*started'; then
    log_info "  !   sketchybar service is currently running. Stopping it first..."
    output=$(brew services stop sketchybar 2>&1)
    exit_code=$?
    echo "$output" | output_stream
    if [ $exit_code -eq 0 ]; then
        log_success "sketchybar service stopped successfully."
    else
        log_fatal "Failed to stop sketchybar service."
        return 1
    fi
else
    log_info "  !   sketchybar service is not running. Proceeding..."
fi

# Try and update sketchybar to the latest version
log_user "Updating sketchybar to the latest version..."
output=$(brew upgrade FelixKratz/formulae/sketchybar 2>&1)
exit_code=$?  # Capture exit status
# Filter output but maintain original exit code
echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
if [ $exit_code -eq 0 ]; then
    log_success "sketchybar update successful"
else
    log_fatal "sketchybar update failed"
fi

# Clone and build sketchybar-app-font
log_user "Setting up sketchybar app font..."
TEMP_DIR=$(mktemp -d)
output=$(git clone https://github.com/kvndrsslr/sketchybar-app-font.git "$TEMP_DIR" 2>&1)
exit_code=$?
echo "$output" | output_stream
if [ $exit_code -ne 0 ]; then
    log_fatal "Failed to clone sketchybar-app-font repository"
    rm -rf "$TEMP_DIR"
    return 1
else
    cd "$TEMP_DIR" || return 1
    
    # Install pnpm if not available
    if ! command -v pnpm &> /dev/null; then
        log_info "Installing pnpm..."

        if ! command -v npm &> /dev/null; then
            log_fatal "npm is not installed. Please install Node.js which includes npm."
            # Cleanup
            cd - > /dev/null 2>&1 || true  # Don't fail if cd - doesn't work
            rm -rf "$TEMP_DIR"
            return 1
        fi

        output=$(npm install -g pnpm 2>&1)
        exit_code=$?
        echo "$output" | output_stream
        if [ $exit_code -eq 0 ]; then
            log_success "pnpm installed successfully!"
        else
            log_fatal "pnpm installation failed."
            # Cleanup
            cd - > /dev/null 2>&1 || true  # Don't fail if cd - doesn't work
            rm -rf "$TEMP_DIR"
            return 1
        fi
    fi
    
    # Build and install
    TARGET_SCRIPT="$XDG_CONFIG_HOME/sketchybar/plugins/icon_map_fn.sh"
    output=$(pnpm install 2>&1)
    exit_code1=$?
    echo "$output" | output_stream
    output=$(pnpm run build:install "$TARGET_SCRIPT" 2>&1)
    exit_code2=$?
    echo "$output" | output_stream
    if [ $exit_code1 -eq 0 ] && [ $exit_code2 -eq 0 ]; then
        log_success "Sketchybar app font installed successfully!"
    else
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
output=$(brew services start sketchybar 2>&1)
exit_code=$?  # Capture exit status
echo "$output" | output_stream
if [ $exit_code -eq 0 ]; then
    log_success "Started sketchybar service."
else
    log_fatal "Failed to start sketchybar service."
    return 1
fi

log_success "sketchybar installation and configuration complete!"
return 0