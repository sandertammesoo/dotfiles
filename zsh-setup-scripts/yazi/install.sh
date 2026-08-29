#!/usr/bin/env zsh
#
# Deploy the yazi flavors and plugins pinned in xdg_config/yazi/package.toml.
#
# dotbot links package.toml into ~/.config/yazi, so the pins are tracked here,
# but the packages themselves are not: `ya pkg install` clones each one into
# ~/.cache/yazi/packages and deploys it to ~/.config/yazi/flavors/, which is
# vendor content that does not belong in a public repo. Without this step yazi
# starts with no tokyo-night flavor and falls back to its built-in colors.
#
# Whitelisted in install-all's allowed_installer_paths — without that entry
# this file is silently skipped.

if [[ "${SKIP_YAZI_SETUP:-false}" == "true" ]]; then
  log_skip "Skipping yazi package setup."
  return 0
fi

if ! command -v ya &> /dev/null; then
  log_warn "ya not installed — it ships with yazi, declared in brewfiles/Brewfile."
  log_warn "Run 'brew bundle', then re-run this installer."
  return 1
fi

local yazi_config="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"

if [[ ! -f "${yazi_config}/package.toml" ]]; then
  log_warn "${yazi_config}/package.toml is missing — run ./run-dotbot first."
  return 1
fi

# `ya pkg install` is idempotent: a package already deployed at the pinned
# revision is reported and skipped, so this is safe on every install-all run.
# Upgrading to newer upstream revisions stays a deliberate 'ya pkg upgrade',
# which rewrites the pins in package.toml and shows up as a diff in this repo.
log_info "Deploying yazi packages from package.toml..."
if ya pkg install; then
  log_success "yazi packages deployed."
else
  log_warn "ya pkg install failed — yazi will fall back to its built-in colors."
  return 1
fi

return 0
