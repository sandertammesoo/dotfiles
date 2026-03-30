#!/bin/bash
#
# Fetch Claude subscription usage from Anthropic OAuth API.
# Writes /tmp/claude_rate_limits.json and triggers the sketchybar event.
#
# Called by claude_limits.sh when the cache is stale or missing.
# Also still triggered by ~/.claude/statusline-command.sh during active sessions.

CACHE_FILE="/tmp/claude_rate_limits.json"
LOCK_FILE="/tmp/claude_rate_limits.lock"
CACHE_TTL=300  # seconds (5 minutes)

# ---- Guard: skip if cache is already fresh --------------------------------
if [[ -f "$CACHE_FILE" ]]; then
  updated_at=$(jq -r '.updated_at // 0' "$CACHE_FILE" 2>/dev/null)
  now=$(date +%s)
  if (( now - updated_at < CACHE_TTL )); then
    exit 0
  fi
fi

# ---- Guard: only one fetch at a time --------------------------------------
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  exit 0  # another instance is already fetching
fi

# ---- Read OAuth token from macOS keychain ---------------------------------
access_token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
  | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
if [[ -z "$access_token" ]]; then
  exit 1
fi

# ---- Call Anthropic OAuth usage API ---------------------------------------
response=$(curl -sf --max-time 10 \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

if [[ -z "$response" ]]; then
  exit 1
fi

# ---- Parse: utilization is 0–1, resets_at is ISO 8601 UTC ----------------
five_pct=$(printf '%s' "$response" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
five_resets_at=$(printf '%s' "$response" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
week_pct=$(printf '%s' "$response" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
week_resets_at=$(printf '%s' "$response" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)

# ---- Convert ISO 8601 UTC to Unix timestamp (macOS date) ------------------
iso_to_epoch() {
  local iso="$1"
  [[ -z "$iso" || "$iso" == "null" ]] && return
  # Strip trailing Z or +00:00 offset, then parse with macOS date
  local stripped="${iso%Z}"
  stripped="${stripped%+00:00}"
  stripped="${stripped%.*}"  # strip sub-seconds if present
  TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" "+%s" 2>/dev/null
}

five_reset=$(iso_to_epoch "$five_resets_at")
week_reset=$(iso_to_epoch "$week_resets_at")

# ---- Write cache atomically -----------------------------------------------
tmp=$(mktemp "${CACHE_FILE}.XXXXXX")
printf '{"five_pct":%s,"five_reset":%s,"week_pct":%s,"week_reset":%s,"updated_at":%s}\n' \
  "${five_pct:-null}" "${five_reset:-null}" \
  "${week_pct:-null}" "${week_reset:-null}" \
  "$(date +%s)" \
  > "$tmp"
mv "$tmp" "$CACHE_FILE"

sketchybar --trigger claude_limits_update 2>/dev/null || true
