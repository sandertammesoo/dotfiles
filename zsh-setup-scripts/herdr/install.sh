#!/usr/bin/env zsh
#
# Declare the herdr plugin set and register the Claude Code session-title hook.
#
# dotbot links individual files under ~/.config/herdr — config.toml and the
# worktrunk plugin's config.toml — because that directory also holds sockets,
# logs and session state (see dotbot.conf.yaml). herdr keeps its
# installed-plugin state in ~/.config/herdr/plugins.json alongside them and
# offers no export command, so the plugin set is re-declared here rather than
# tracked as a file.
#
# Whitelisted in install-all's allowed_installer_paths — without that entry
# this file is silently skipped.

if [[ "${SKIP_HERDR_SETUP:-false}" == "true" ]]; then
  log_skip "Skipping herdr plugin setup."
  return 0
fi

if ! command -v herdr &> /dev/null; then
  log_warn "herdr not installed — it is declared in brewfiles/Brewfile."
  log_warn "Run 'brew bundle', then re-run this installer."
  return 1
fi

# Ordered "<plugin-id> <owner/repo>" pairs. herdr installs a plugin by
# repository but addresses it by the id declared in its herdr-plugin.toml, so
# both are needed: the repo to fetch it, the id to test for presence and to
# invoke its actions.
local -a herdr_plugins=(
  "ray.plugin-manager speardragon/herdr-plugin-manager"
  "bcihanc.claude-session-title bcihanc/herdr-claude-session-title"
  "herdr-automatic-rename qu8n/herdr-automatic-rename"
  "worktrunk devashish2203/herdr-worktrunk"
)

local result=0
local installed
installed="$(herdr plugin list 2> /dev/null)"

local entry plugin_id plugin_repo
for entry in "${herdr_plugins[@]}"; do
  plugin_id="${entry%% *}"
  plugin_repo="${entry#* }"

  # Re-installing a present plugin advances it to the newest upstream commit.
  # Skip instead, so a routine install-all never silently changes plugin code;
  # updating stays a deliberate 'herdr plugin install <owner/repo>' by hand.
  if [[ "$installed" == *"$plugin_id"* ]]; then
    log_skip "herdr plugin already installed: ${plugin_id}"
    continue
  fi

  log_info "Installing herdr plugin ${plugin_id} from ${plugin_repo}..."
  if herdr plugin install --yes "$plugin_repo"; then
    log_success "Installed herdr plugin: ${plugin_id}"
  else
    log_warn "Failed to install herdr plugin ${plugin_id} from ${plugin_repo}."
    result=1
  fi
done

# jq backs every rename pass in herdr-automatic-rename. Without it the engine
# exits before it names anything, so this is a warning rather than a failure.
# Unconditional on purpose: $installed is the list from BEFORE the loop, so a
# fresh machine — the one that actually needs the warning — would not match it.
if ! command -v jq &> /dev/null; then
  log_warn "jq not on PATH — herdr-automatic-rename will not name or number anything."
fi

# The session-title plugin ships a Claude Code hook but does not register it.
# Installing a plugin never runs its actions, by design: an action is arbitrary
# shell, and this one writes ~/.claude/settings.json. Registration is therefore
# a second, explicit step.
local session_title_id="bcihanc.claude-session-title"

if ! herdr plugin list 2> /dev/null | grep -q "$session_title_id"; then
  log_warn "${session_title_id} is not installed — skipping hook registration."
  return $result
fi

# The install action is idempotent — it strips every entry carrying the marker
# before adding one back — but it rewrites settings.json and leaves a
# .bak-claude-session-title copy each run. Only invoke it when the hook is
# genuinely absent from either the hooks directory or settings.json.
local claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
local hook_marker="herdr-claude-session-title.sh"

if [[ -x "${claude_dir}/hooks/${hook_marker}" ]] \
  && grep -q "$hook_marker" "${claude_dir}/settings.json" 2> /dev/null; then
  log_success "Claude Code session-title hook already registered."
else
  log_info "Registering the Claude Code session-title hook..."
  if herdr plugin action invoke "${session_title_id}.install"; then
    log_success "Session-title hook registered."
    log_info "Restart running Claude Code sessions — hooks are read at start."
  else
    log_warn "Could not register the session-title hook; herdr may need to be running."
    log_warn "Retry by hand with:"
    log_warn "  herdr plugin action invoke ${session_title_id}.install"
    result=1
  fi
fi

# python3 backs the hook. Without it every event exits silently and no title is
# ever reported, so this is a warning rather than a failure.
if ! command -v python3 &> /dev/null; then
  log_warn "python3 not on PATH — the session-title hook will report nothing."
fi

return $result
