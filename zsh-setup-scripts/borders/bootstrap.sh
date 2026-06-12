#!/usr/bin/env zsh

# Check if Homebrew is installed
require_brew || return 1

# Homebrew 6.0+ won't load a non-official tap until it's trusted (HOMEBREW_REQUIRE_TAP_TRUST).
brew_trust_tap "felixkratz/formulae"

# Install borders if not installed
brew_install_if_missing "borders" "FelixKratz/formulae/borders" || return 1

# Stop borders service if it's running
log_user "Checking if borders service is running..."
run_cmd="pgrep -x borders"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?
echo "$output" | output_stream VERBOSE
if [ $exit_code -eq 0 ]; then
    log_user "borders service is currently running. Stopping it first..."
    run_cmd="brew services stop borders"
    log_verbose "Running command: $run_cmd"
    output=$(eval "$run_cmd" 2>&1)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "$output" | output_stream
        log_success "borders service stopped successfully."
    else
        echo "$output" | output_stream FATAL
        log_fatal "Failed to stop borders service."
        return 1
    fi
else
    log_skip "borders service is not running. Proceeding..."
fi

# Update borders to the latest version
log_user "Updating borders to the latest version..."
run_cmd="brew upgrade FelixKratz/formulae/borders"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "$output" | grep -v "already installed" | output_stream 2>/dev/null
    log_success "borders update successful"
else
    # Non-fatal: a working version is already installed (brew_install_if_missing passed
    # above), so a failed upgrade — e.g. no bottle yet for a beta macOS, forcing a source
    # build that fails — shouldn't abort setup. Mirrors the yabai bootstrap's behaviour.
    echo "$output" | output_stream WARN
    log_warn "borders upgrade failed; keeping the installed version and continuing."
fi

# Start borders service
log_user "Starting borders service..."
run_cmd="brew services start borders"
log_verbose "Running command: $run_cmd"
output=$(eval "$run_cmd" 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "$output" | output_stream VERBOSE
    log_success "Started borders service."
else
    echo "$output" | output_stream FATAL
    log_fatal "Failed to start borders service."
    return 1
fi

log_success "borders installation and configuration complete!"
return 0
