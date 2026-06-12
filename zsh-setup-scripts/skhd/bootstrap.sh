#!/usr/bin/env zsh

# Check if Homebrew is installed
require_brew || return 1

# Homebrew 6.0+ won't load a non-official tap until it's trusted (HOMEBREW_REQUIRE_TAP_TRUST).
brew_trust_tap "asmvik/formulae"

# Install skhd if not installed
brew_install_if_missing "skhd" "asmvik/formulae/skhd" || return 1

# Try and stop skhd service if it's running using skhd command
log_user "Checking if skhd service is running..."
run_cmd="pgrep -x skhd"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream
    log_user "skhd service is currently running. Stopping it first..."
    run_cmd="skhd --stop-service"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?  # Capture exit status
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream
        log_success "skhd service stopped successfully."
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to stop skhd service."
        return 1
    fi
else
    echo "$output" | output_stream VERBOSE
    log_skip "skhd service is not running. Proceeding..."
fi

# Try and update skhd to the latest version
log_user "Updating skhd to the latest version..."
run_cmd="brew upgrade asmvik/formulae/skhd"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
# Filter output but maintain original exit code
if [ $exit_code -eq 0 ]; then
    echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
    log_success "skhd update successful"
else
    # Non-fatal: a working version is already installed (brew_install_if_missing passed
    # above), so a failed upgrade — e.g. no bottle yet for a beta macOS, forcing a source
    # build that fails — shouldn't abort setup. Mirrors the yabai bootstrap's behaviour.
    echo "$output" | output_stream WARN
    log_warn "skhd upgrade failed; keeping the installed version and continuing."
fi

# Try and start skhd service
log_user "Starting skhd service..."
run_cmd="skhd --start-service"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?  # Capture exit status
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream
    log_success "Started skhd service."
else
    echo "$output" | output_stream FATAL
    log_fatal "Failed to start skhd service."
    return 1
fi

log_success "skhd installation and configuration complete!"
return 0