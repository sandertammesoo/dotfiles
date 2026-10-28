#!/usr/bin/env zsh
#
# Install mise from the official release script, not Homebrew.
#
# The standalone binary at ~/.local/bin/mise starts faster than the Homebrew
# build and updates itself with 'mise self-update'. Homebrew must not also
# install it: 'mise activate' bakes the absolute binary path into the
# _mise_hook function, so a second copy that later disappears breaks every
# open shell with "no such file or directory".
#
# Whitelisted in install-all's allowed_installer_paths — without that entry
# this file is silently skipped.

if [[ "${SKIP_MISE_SETUP:-false}" == "true" ]]; then
  log_skip "Skipping mise installation."
  return 0
fi

local mise_bin="$HOME/.local/bin/mise"
local result=0

if [[ -x "$mise_bin" ]]; then
  log_success "mise already installed: $("$mise_bin" --version 2> /dev/null)"
else
  log_info "Installing mise to ${mise_bin}..."
  if curl -fsSL https://mise.run | MISE_INSTALL_PATH="$mise_bin" MISE_INSTALL_HELP=0 sh 2>&1 | output_stream \
    && [[ -x "$mise_bin" ]]; then
    log_success "mise installed: $("$mise_bin" --version 2> /dev/null)"
  else
    log_failure "mise installation failed"
    result=1
  fi
fi

# /opt/homebrew/bin comes before ~/.local/bin on PATH, so a leftover Homebrew
# copy wins over the standalone binary.
if command -v brew &> /dev/null && brew list --formula mise &> /dev/null; then
  log_warn "Homebrew also has mise installed; it takes precedence on PATH."
  log_warn "Remove it with: brew uninstall mise"
  result=1
fi

return $result
