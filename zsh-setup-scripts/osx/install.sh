#!/usr/bin/env zsh
src "$(basename "${(%):-%x}")"

# Ensure script is only executed on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  error " ✗ MacOS not detected!"
  return  # Use 'return' if sourced, 'exit' if standalone
fi

# Update all available macOS software updates
user "Checking for macOS software updates..."
if sudo softwareupdate -i -a | info_stream; then
  success " ✓ Software update completed."
else
  fail " ✗ Software update failed."
fi
