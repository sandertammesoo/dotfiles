#!/usr/bin/env zsh
#
# brew-drift: the local config (profile mac) and the weekly reminder.
# install-server writes the server profile itself and has no reminder:
# a headless server has no GUI session for the notification.
#
# Whitelisted in install-all's allowed_installer_paths — without that entry
# this file is silently skipped.

if [[ "${SKIP_BREW_DRIFT_SETUP:-false}" == "true" ]]; then
  log_skip "Skipping brew-drift setup."
  return 0
fi

source zsh-setup-scripts/brew-drift/setup.sh || return 1

local result=0
brew_drift_write_local_config mac || result=1
brew_drift_install_reminder || result=1
return $result
