#!/bin/bash

# Claude Code rate limit indicator plugin
# Reads /tmp/claude_rate_limits.json written by ~/.claude/statusline-command.sh

CACHE_FILE="/tmp/claude_rate_limits.json"
STALE_AFTER=300  # seconds (5 minutes)

# Catppuccin Mocha colours (ARGB)
COLOR_DIM=0xff7f849c
COLOR_PEACH=0xfffab387
COLOR_RED=0xfff38ba8
COLOR_WHITE=0xffffffff

# Blank items and exit if cache is missing or stale
if [[ ! -f "$CACHE_FILE" ]]; then
  sketchybar --set claude_5h label="--" label.color=$COLOR_WHITE icon.color=$COLOR_WHITE \
             --set claude_7d label="--" label.color=$COLOR_WHITE icon.color=$COLOR_WHITE
  exit 0
fi

updated_at=$(jq -r '.updated_at // 0' "$CACHE_FILE" 2>/dev/null)
now=$(date +%s)
if (( now - updated_at > STALE_AFTER )); then
  sketchybar --set claude_5h label="--" label.color=$COLOR_WHITE icon.color=$COLOR_WHITE \
             --set claude_7d label="--" label.color=$COLOR_WHITE icon.color=$COLOR_WHITE
  exit 0
fi

five_pct=$(jq -r '.five_pct // empty' "$CACHE_FILE" 2>/dev/null)
five_reset=$(jq -r '.five_reset // empty' "$CACHE_FILE" 2>/dev/null)
week_pct=$(jq -r '.week_pct // empty' "$CACHE_FILE" 2>/dev/null)
week_reset=$(jq -r '.week_reset // empty' "$CACHE_FILE" 2>/dev/null)

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

  # if (( pct_int >= 50 )) && [[ -n "$resets_at" && "$resets_at" != "null" ]]; then
  if [[ -n "$resets_at" && "$resets_at" != "null" ]]; then
    local now remaining timer
    now=$(date +%s)
    remaining=$(( resets_at - now ))
    if (( remaining <= 0 )); then
      # Reset window has passed — usage is back to 0%
      pct_int=0
      color=$COLOR_WHITE
      label="0%"
    else
      timer=$(format_duration "$remaining")
      label="${pct_int}% ${timer}"
    fi
  fi

  sketchybar --set "$item" label="$label" label.color=$color icon.color=$color
}

update_item "claude_5h"  "$five_pct"  "$five_reset"
update_item "claude_7d"  "$week_pct"  "$week_reset"
