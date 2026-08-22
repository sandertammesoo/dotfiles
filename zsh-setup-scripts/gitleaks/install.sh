#!/usr/bin/env zsh
#
# Verify the machine-wide secret gate.
#
# core.hooksPath is declared in the tracked git config (xdg_config/git/config)
# rather than written here, because `git config --global` would bake an
# absolute /Users/<name> path into a file this repo tracks and shares across
# machines. This installer therefore checks the wiring instead of creating it.
#
# Whitelisted in install-all's allowed_installer_paths — without that entry
# this file is silently skipped.

if [[ "${SKIP_GITLEAKS_SETUP:-false}" == "true" ]]; then
  log_skip "Skipping secret-gate verification."
  return 0
fi

local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
local expected="${config_home}/git/hooks"
local hook="${expected}/pre-commit"
local result=0

# 1. The hook must exist and be executable, which dotbot's link provides.
if [[ -x "$hook" ]]; then
  log_success "Pre-commit secret gate present: ${hook}"
else
  log_warn "Pre-commit hook missing or not executable at ${hook} — run ./run-dotbot"
  result=1
fi

# 2. git must actually point at it. The configured value is usually the
#    literal '~/.config/git/hooks'; git expands the tilde when running hooks,
#    so compare against both forms rather than the raw string alone.
local configured
configured="$(git config --get core.hooksPath)"

if [[ -z "$configured" ]]; then
  log_warn "core.hooksPath is unset — the gate applies to no repository."
  log_warn "Expected it from xdg_config/git/config; is ~/.config/git linked?"
  result=1
elif [[ "${configured/#\~/$HOME}" == "$expected" ]]; then
  log_success "core.hooksPath → ${configured} (gate active in all repos)"
else
  log_warn "core.hooksPath is '${configured}', expected '${expected}'."
  log_warn "A stale absolute path from an earlier install? Remove it with:"
  log_warn "  git config --global --unset core.hooksPath"
  result=1
fi

# 3. Without the binary the hook warns and allows the commit by design, so
#    this is a warning rather than a failure.
if command -v gitleaks &> /dev/null; then
  log_success "gitleaks $(gitleaks version 2> /dev/null) available"
else
  log_warn "gitleaks not installed — the hook will warn and allow every commit."
  log_warn "It is declared in brewfiles/Brewfile; run 'brew bundle' to install it."
fi

# 4. Repositories that set core.hooksPath locally silently bypass the gate.
if command -v gitleaks &> /dev/null; then
  log_info "Run 'secrets-audit --hooks' to list repositories that override it."
fi

return $result
