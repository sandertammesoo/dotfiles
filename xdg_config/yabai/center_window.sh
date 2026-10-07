#!/usr/bin/env bash
# Center a floating window on the focused display, keeping its size.
# Usage: center_window.sh [WINDOW_ID]   (defaults to $YABAI_WINDOW_ID)
#
# Queries only the one window and the focused display. A global
# `yabai -m query --windows` here would trigger the minimize bug
# (.claude/YABAI_MINIMIZE_BUG/).

win_id="${1:-$YABAI_WINDOW_ID}"
[[ -n "$win_id" ]] || exit 1

win=$(yabai -m query --windows --window "$win_id") || exit 1
display=$(yabai -m query --displays --display) || exit 1

[[ "$(jq -r '."is-floating"' <<<"$win")" == "true" ]] || exit 0

# Move to the focused display first so macOS assigns the window to it.
display_index=$(jq -r '.index' <<<"$display")
[[ "$(jq -r '.display' <<<"$win")" == "$display_index" ]] \
  || yabai -m window "$win_id" --display "$display_index"

read -r x y < <(jq -rn --argjson w "$win" --argjson d "$display" \
  '[($d.frame.x + ($d.frame.w - $w.frame.w) / 2 | floor),
    ($d.frame.y + ($d.frame.h - $w.frame.h) / 2 | floor)] | @tsv')

yabai -m window "$win_id" --move "abs:${x}:${y}"
