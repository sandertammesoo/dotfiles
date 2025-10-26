#!/usr/bin/env zsh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_fatal "Homebrew not installed. Please install it first."
    return 1
fi

# Install yabai if not installed
if command -v yabai &> /dev/null; then
    log_success "yabai is already installed."
else
    log_info "  !   yabai not found. Proceeding with installation."
    log_user "Installing yabai..."
    if brew install koekeishiya/formulae/yabai 2>&1 | output_stream; then
        log_success "yabai installed successfully!"
    else
        log_fatal "yabai installation failed!"
        return 1
    fi
fi
# Verify yabai installation
if ! command -v yabai &> /dev/null; then
    log_fatal "yabai installation verification failed!"
    return 1
fi

# Install borders if not installed
if command -v borders &> /dev/null; then
    log_success "borders is already installed."
else
    log_info "  !   borders not found. Proceeding with installation."
    log_user "Installing borders..."
    if brew install felixkratz/formulae/borders 2>&1 | output_stream; then
        log_success "borders installed successfully!"
    else
        log_fatal "borders installation failed!"
        return 1
    fi
fi
# Verify borders installation
if ! command -v borders &> /dev/null; then
    log_fatal "borders installation verification failed!"
    return 1
fi

# Stop yabai service if it's running using yabai command
if yabai -m rule --list &> /dev/null; then
    log_info "  !   yabai service is currently running. Stopping it first..."
    if yabai --stop-service 2>&1 | output_stream; then
        log_success "yabai service stopped successfully."
    else
        log_fatal "Failed to stop yabai service."
        return 1
    fi
else
    log_info "  !   yabai service is not running. Proceeding..."
fi

# Try and update yabai to the latest version
log_user "Updating yabai to the latest version..."
output=$(brew upgrade koekeishiya/formulae/yabai 2>&1)
exit_code=$?  # Capture exit status
# Filter output but maintain original exit code
echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
if [ $exit_code -eq 0 ]; then
    log_success "yabai update successful"
else
    log_fatal "yabai update failed"
fi

# Get the hash of yabai
YABAI_HASH=$(shasum -a 256 $(which yabai) | awk '{print $1}')

# Check if sudoers file already contains the correct line
SUDOERS_FILE="/private/etc/sudoers.d/yabai"
UPDATE_FILE=false
if [ -f "$SUDOERS_FILE" ]; then
    if sudo grep -q "$YABAI_HASH" "$SUDOERS_FILE"; then
        log_success "Sudoers file for yabai already configured."
    else
        log_warn "Sudoers file for yabai exists but does not contain the correct hash. It will be updated."
        # Backup existing sudoers file if it exists
        log_info "Backing up existing sudoers file..."
        sudo cp "$SUDOERS_FILE" "${SUDOERS_FILE}.bak_$(date +%Y%m%d%H%M%S)"
        UPDATE_FILE=true
    fi
else
    log_info "  !   Sudoers file for yabai not found. It will be created."
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
fi

# Load the scripting addition
log_user "Loading yabai scripting addition..."
if sudo yabai --load-sa; then
    log_success "yabai scripting addition loaded successfully."
else
    log_fatal "Failed to load yabai scripting addition."
    return 1
fi

log_debug "Configuring macOS system settings for optimal yabai performance..."
# Disable macOS window animations for better performance with yabai
defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder # or logout and login

# to reset system defaults, delete the key instead
# defaults delete com.apple.finder DisableAllAnimations

# Start yabai service
log_user "Starting yabai service..."
if yabai --start-service 2>&1 | output_stream; then
    log_success "Started yabai service."
else
    log_fatal "Failed to start yabai service."
    return 1
fi

log_success "Yabai installation and configuration complete!"
return 0