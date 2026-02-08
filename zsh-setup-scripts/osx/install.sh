#!/usr/bin/env zsh
# exec 2> >(error_stream)

if [[ "${SKIP_OSX_UPDATES:-false}" == "true" ]] || [[ "${SKIP_UPDATES:-false}" == "true" ]]; then
  log_skip "Skipping macOS software updates."
  return 0
fi

log_debug "Ensure script is only executed on macOS"
if [[ "$(uname)" != "Darwin" ]]; then
  log_fatal "MacOS not detected!"
  return 1
fi

# Check for macOS software updates
log_info "Checking for macOS software updates..."
log_info "    Note: This may require an additional password prompt"
log_info "    Waiting 30 seconds for input, then skipping..."
log_user "Continue with software update? [Y/n] "
if ! read -t 30 reply; then
    echo ""
    log_skip "Timed out waiting for input. Skipping software updates."
    return 1
fi

if [[ "$reply" =~ ^[Nn] ]]; then
    log_skip "Skipping software updates."
    return 1
fi
echo ""

UPDATES=$(softwareupdate -l --no-scan 2>&1)
if [[ $UPDATES == *"No new software available."* ]]; then
  log_success "No software updates available."
  return 0
else
  log_success "Updates found, proceeding with download:"
  echo "$UPDATES" | grep -E '^\*' | sed 's/^\* //' | output_stream
  # Download and install all updates
  if softwareupdate -i -a | output_stream; then
    log_success "Software update completed."
    return 0
  else
    log_failure "Software update installation failed."
    return 1
  fi
fi

# if sudo softwareupdate -i -a | output_stream; then
#   log_success "Software update completed."
# else
#   log_fatal "Software update failed."
# fi
