#!/usr/bin/env zsh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_fatal "Homebrew not installed. Please install it first."
    return 1
fi

# Install skhd if not installed
if command -v skhd &> /dev/null; then
    log_success "skhd is already installed."
else
    log_user "skhd not found. Proceeding with installation."
    log_user "Installing skhd..."
    if brew install koekeishiya/formulae/skhd 2>&1 | output_stream; then
        log_success "skhd installed successfully!"
    else
        log_fatal "skhd installation failed!"
        return 1
    fi
fi
# Verify skhd installation
if ! command -v skhd &> /dev/null; then
    log_fatal "skhd installation verification failed!"
    return 1
fi

# Stop skhd service if it's running using skhd command
if skhd --restart-service &> /dev/null; then
    log_user "skhd service is currently running. Stopping it first..."
    if skhd --stop-service 2>&1 | output_stream; then
        log_success "skhd service stopped successfully."
    else
        log_fatal "Failed to stop skhd service."
        return 1
    fi
else
    log_skip "skhd service is not running. Proceeding..."
fi

# Try and update skhd to the latest version
log_user "Updating skhd to the latest version..."
output=$(brew upgrade koekeishiya/formulae/skhd 2>&1)
exit_code=$?  # Capture exit status
# Filter output but maintain original exit code
echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
if [ $exit_code -eq 0 ]; then
    log_success "skhd update successful"
else
    log_fatal "skhd update failed"
fi

# Start skhd service
log_user "Starting skhd service..."
if skhd --start-service 2>&1 | output_stream; then
    log_success "Started skhd service."
else
    log_fatal "Failed to start skhd service."
    return 1
fi

log_success "skhd installation and configuration complete!"
return 0