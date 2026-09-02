#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script. The timer and the wl_volume_change
# trigger supply no $INFO, so read the system volume directly for those.

WL_VOL="$HOME/.local/bin/wl-vol"
WL_KEYS="$HOME/.local/bin/wl-keys"

# This item already polls, so it is also where the media-key bindings get kept
# in step with Wave Link. wl-keys reloads skhd only when the state changes.
[ -x "$WL_KEYS" ] && "$WL_KEYS" sync

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
fi

[ -z "$VOLUME" ] && exit 0

case $VOLUME in
  [6-9][0-9]|100) ICON="􀊩"
  ;;
  [3-5][0-9]) ICON="􀊥"
  ;;
  [1-9]|[1-2][0-9]) ICON="􀊡"
  ;;
  *) ICON="􀊣"
esac

LABEL="$VOLUME%"

# Wave Link mixes its own audio at its own level, so the system percentage
# alone does not say how loud the headphones are. Append the level of the mix
# that the Main output listens to, whenever Wave Link is running.
if STATUS=$("$WL_VOL" status 2>/dev/null); then
  WL_LEVEL=$(printf '%s' "$STATUS" | cut -f2)
  WL_MUTED=$(printf '%s' "$STATUS" | cut -f3)

  if [ "$WL_MUTED" = "true" ]; then
    LABEL="$LABEL · WL muted"
  else
    LABEL="$LABEL · WL $WL_LEVEL%"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
