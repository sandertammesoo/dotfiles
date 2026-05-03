#!/usr/bin/env zsh

# Persist CLAUDE_CONFIG_DIR across sessions via a state file
if [[ -f "$HOME/.claude/.active-profile" ]]; then
  _profile="$(< "$HOME/.claude/.active-profile")"
  [[ "$_profile" == "personal" ]] && export CLAUDE_CONFIG_DIR="$HOME/.claude/profiles/personal"
  unset _profile
fi