# Phase 1 Implementation Complete ✅

## What Changed

### Modified Files
1. **`xdg_config/yabai/yabairc`**
   - Added 4 debug signals (lines 17-20)
   - Logs minimize, deminimize, focus, and app switch events
   - **Fixed**: Changed deprecated `minimized` → `"is-minimized"`

2. **`xdg_config/yabai/application-activated.zsh`**
   - **Fixed**: Changed `.minimized==0` → `.["is-minimized"]==false`
   - **Fixed**: Changed `.floating==0` → `.["is-floating"]==false`

### New Files Created
1. **`xdg_config/yabai/debug_minimize.sh`** - Helper script with commands:
   - `tail` - Monitor log in real-time
   - `clear` - Clear log and start fresh
   - `show` - Show all events
   - `count` - Show statistics
   - `apps` - Show currently minimized windows
   - **Fixed**: Uses correct field name `.["is-minimized"]`

2. **`.claude/PHASE1_DEBUG_GUIDE.md`** - Complete testing guide

### Services Restarted
- ✅ Yabai restarted and debug logging is now active

---

## 🔍 Important Discovery: Deprecated Field Names

During implementation, we discovered the configuration was using **deprecated Yabai field names** that caused `minimized=null` in all queries.

### Yabai Field Name Changes
Yabai changed from short names to `is-*` prefixed names:

| Old (Deprecated) | New (Current) | Notes |
|-----------------|---------------|-------|
| `minimized` | `"is-minimized"` | Must quote in jq: `.["is-minimized"]` |
| `visible` | `"is-visible"` | Must quote in jq |
| `hidden` | `"is-hidden"` | Must quote in jq |
| `floating` | `"is-floating"` | Must quote in jq |
| `sticky` | `"is-sticky"` | Must quote in jq |

### What Was Broken
Before the fix:
```bash
# This returned null instead of true/false
yabai -m query --windows | jq '.[] | .minimized'

# Debug log showed: minimized=null
```

After the fix:
```bash
# This correctly returns true/false
yabai -m query --windows | jq '.[] | .["is-minimized"]'

# Debug log shows: is-minimized=true or is-minimized=false
```

### Verification
Running `debug_minimize.sh apps` now correctly shows:
```
Currently minimized windows per app:
==================================================
Brave Browser: window 234830 on space 7
Brave Browser: window 234841 on space 7
Brave Browser: window 90580 on space 5
Claude: window 234690 on space 7
Notion Calendar: window 204471 on space 1
Slack: window 179971 on space 7
```

Before the fix, this would show nothing because the query couldn't detect minimized windows.

---

## Quick Start

### Step 1: Clear the log
```bash
~/.config/yabai/debug_minimize.sh clear
```

### Step 2: Open a new terminal and monitor
```bash
~/.config/yabai/debug_minimize.sh tail
```

### Step 3: Reproduce the bug
1. Minimize windows from several different apps
2. Click dock or use Cmd+Tab to focus a minimized window
3. Watch the terminal - you'll see every window that deminimizes

### Step 4: Analyze
```bash
~/.config/yabai/debug_minimize.sh count
```

---

## Critical Finding Expected

Since you said **ALL windows from ALL apps** deminimize (not just the focused app), the log will likely show one of these patterns:

### Pattern A: Simultaneous deminimize cascade
```
[20:30:15] APP SWITCHED: 1234 - Chrome
[20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[20:30:15] DEMINIMIZED: 9877 (Terminal)         ← All apps!
[20:30:15] DEMINIMIZED: 9878 (Visual Studio Code)
[20:30:15] DEMINIMIZED: 9879 (Finder)
```

This would indicate either:
- A signal handler is triggering a global deminimize
- Something in your config is looping through all windows
- A very unusual macOS behavior

### Pattern B: Chain reaction from focus events
```
[20:30:15] FOCUSED: 9876 (Google Chrome) - minimized=1
[20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[20:30:15] FOCUSED: 9877 (Terminal) - minimized=0    ← Unexpected focus!
[20:30:15] DEMINIMIZED: 9877 (Terminal)
```

This would suggest the `window_focused` signal is somehow focusing other windows.

---

## Next Steps

1. **Run the tests** using the guide above
2. **Share the output** of:
   - The raw log when reproducing the bug
   - The count summary
3. **I'll analyze** the event sequence
4. **We'll implement** the targeted fix

The debug data will tell us exactly which signal or configuration is causing ALL windows to deminimize, and we can fix it precisely.

---

## Suspicions

Given that ALL apps are affected (not just the focused one), I suspect one of these:

1. **The `window_focused` signal to sketchybar** might be triggering something
2. **The `application-activated.zsh` script** might be interfering
3. **A space setup script** might be running unexpectedly
4. **Some other signal handler** is looping through all windows

The debug log will show us which one!
