#!/bin/bash

# Claude Code rate limit indicator plugin
# Reads /tmp/claude_rate_limits.json written by ~/.claude/statusline-command.sh

CACHE_FILE="/tmp/claude_rate_limits.json"

[[ ! -f "$CACHE_FILE" ]] && exit 0

five_pct=$(jq -r '.five_pct // empty' "$CACHE_FILE" 2>/dev/null)
five_reset=$(jq -r '.five_reset // empty' "$CACHE_FILE" 2>/dev/null)
week_pct=$(jq -r '.week_pct // empty' "$CACHE_FILE" 2>/dev/null)
week_reset=$(jq -r '.week_reset // empty' "$CACHE_FILE" 2>/dev/null)

# Catppuccin Mocha colours (ARGB)
COLOR_DIM=0xff7f849c
COLOR_PEACH=0xfffab387
COLOR_RED=0xfff38ba8
COLOR_WHITE=0xffffffff

format_duration() {
  local secs="$1"
  (( secs <= 0 )) && echo "now" && return
  local days=$(( secs / 86400 ))
  local hours=$(( (secs % 86400) / 3600 ))
  local mins=$(( (secs % 3600) / 60 ))
  if (( days > 0 )); then echo "${days}d${hours}h"
  elif (( hours > 0 )); then echo "${hours}h${mins}m"
  else echo "${mins}m"
  fi
}

update_item() {
  local item="$1"
  local pct="$2"
  local resets_at="$3"

  if [[ -z "$pct" ]]; then
    sketchybar --set "$item" label="--" label.color=$COLOR_WHITE icon.color=$COLOR_WHITE
    return
  fi

  local pct_int
  pct_int=$(printf '%.0f' "$pct")
  local color

  if (( pct_int >= 80 )); then
    color=$COLOR_RED
  elif (( pct_int >= 50 )); then
    color=$COLOR_PEACH
  else
    color=$COLOR_WHITE
  fi

  local label="${pct_int}%"

  if (( pct_int >= 50 )) && [[ -n "$resets_at" && "$resets_at" != "null" ]]; then
    local now remaining timer
    now=$(date +%s)
    remaining=$(( resets_at - now ))
    timer=$(format_duration "$remaining")
    label="${pct_int}% ${timer}"
  fi

  sketchybar --set "$item" label="$label" label.color=$color icon.color=$color
}

update_item "claude_5h"  "$five_pct"  "$five_reset"
update_item "claude_7d"  "$week_pct"  "$week_reset"
