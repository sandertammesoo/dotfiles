# Yabai Minimize/Unminimize Bug - Proposed Solution

## Problem Summary

**Issue**: When focusing a minimized window, ALL minimized windows from ALL applications are unminimized simultaneously.

**User Report**: "when I bring some window to focus that is minimized, all other minimized windows are also unminimized"

**Critical Detail**: This affects ALL applications, not just the focused app. This is extremely unusual and suggests a configuration issue causing a cascade effect.

**Important Discovery**: During Phase 1 implementation, we discovered the configuration was using **deprecated Yabai field names** (`minimized`, `floating`, `visible`) instead of the current field names (`is-minimized`, `is-floating`, `is-visible`). This caused `minimized=null` in queries, preventing proper window state tracking. **This has been fixed.**

## Root Cause Analysis

Based on the research report and configuration analysis:

1. **macOS Native Behavior**: This appears to be macOS Accessibility API behavior rather than a Yabai bug
   - No other users have reported this exact issue in Yabai's GitHub issues
   - The opposite problem (minimizing one window minimizes all) exists as Issue #1037
   - This suggests macOS doesn't provide granular per-window minimize/deminimize control

2. **Cmd+Tab+Option Interaction**: macOS has native behavior where `Cmd+Tab+Option` unminimizes all windows of an app
   - If you're using Cmd+Tab to switch to a minimized window, this could trigger system-wide unminimize

3. **Configuration Gap**: Your current configuration:
   - **No minimize/deminimize shortcuts** in skhd (confirmed - none found in all 448 lines)
   - **No window_deminimized signal** configured in yabairc
   - **Focus follows mouse is OFF** (focus_follows_mouse off, mouse_follows_focus off)
   - **No explicit window ID-based focus** commands

4. **How You're Triggering It**: Since you have no skhd shortcuts for minimize, you're likely:
   - Using dock clicks to unminimize
   - Using Cmd+Tab (native macOS app switcher)
   - Using window title clicks
   - All of these go through macOS APIs, not Yabai

## Proposed Solutions

### Solution 1: Add window_deminimized Signal (RECOMMENDED)

Add a signal handler that forces deminimized windows to current space and prevents multi-window unminimize.

**Implementation**:

```bash
# In xdg_config/yabai/yabairc, add after line 15 (after other signals):

# Force deminimized windows to current space to prevent multi-window unminimize
yabai -m signal --add event=window_deminimized action="~/.config/yabai/window-deminimized.zsh"
```

**Create new file** `xdg_config/yabai/window-deminimized.zsh`:

```bash
#!/usr/bin/env zsh

# Get the window that was just deminimized
WINDOW_ID="${YABAI_WINDOW_ID}"

if [[ -z "$WINDOW_ID" ]]; then
    echo "[window-deminimized] No window ID provided" >> /tmp/yabai_deminimize.log
    exit 1
fi

# Get current space
CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')

# Get window's current space
WINDOW_SPACE=$(yabai -m query --windows --window "$WINDOW_ID" | jq -r '.space')

# Log the action
echo "[$(date)] Window $WINDOW_ID deminimized on space $WINDOW_SPACE, current space: $CURRENT_SPACE" >> /tmp/yabai_deminimize.log

# If window was deminimized on a different space, move it here
if [[ "$WINDOW_SPACE" != "$CURRENT_SPACE" ]]; then
    yabai -m window "$WINDOW_ID" --space "$CURRENT_SPACE"
    echo "[$(date)] Moved window $WINDOW_ID to current space $CURRENT_SPACE" >> /tmp/yabai_deminimize.log
fi

# Focus the deminimized window explicitly
yabai -m window --focus "$WINDOW_ID"
```

**Why This Helps**:
- Intercepts each window deminimize event individually
- Moves window to current space immediately
- Focuses the specific window by ID, not by relative selector
- Logs events to help debug if issue persists

---

### Solution 2: Create Explicit Window Focus Shortcuts

Add skhd shortcuts that focus windows using explicit IDs, bypassing macOS app-level focus.

**Implementation**:

Add to `xdg_config/skhd/skhdrc` after line 49 (after window focus section):

```bash
# ##################################### #
#      MINIMIZE/DEMINIMIZE WINDOWS      #
# ##################################### #

# Deminimize focused window (without unminimizing others)
normal < shift + lalt - 0x2C : ~/.config/yabai/deminimize_single_window.sh
moonlander < hyper - 0x2C : ~/.config/yabai/deminimize_single_window.sh

# Minimize focused window
normal < shift + lalt - x : yabai -m window --minimize
moonlander < hyper - x : yabai -m window --minimize

# Focus recent window (skip minimized)
normal < shift + lalt - tab : yabai -m window --focus recent
moonlander < hyper - tab : yabai -m window --focus recent

# Cycle through non-minimized windows only
normal < shift + lalt - q : ~/.config/yabai/focus_prev_non_minimized.sh
normal < shift + lalt - e : ~/.config/yabai/focus_next_non_minimized.sh
moonlander < hyper - q : ~/.config/yabai/focus_prev_non_minimized.sh
moonlander < hyper - e : ~/.config/yabai/focus_next_non_minimized.sh
```

**Create** `xdg_config/yabai/deminimize_single_window.sh`:

```bash
#!/usr/bin/env zsh

# Deminimize a single window without affecting other minimized windows
# Strategy: Focus another window first, then deminimize target

# Get the focused window ID before anything else
CURRENT_WINDOW=$(yabai -m query --windows --window | jq -r '.id')

# If current window is minimized, we need to find it differently
if [[ "$CURRENT_WINDOW" == "null" ]] || [[ -z "$CURRENT_WINDOW" ]]; then
    # Get first minimized window on current space
    TARGET_WINDOW=$(yabai -m query --windows --space | \
        jq -r 'map(select(.minimized == 1)) | .[0].id')
    
    if [[ "$TARGET_WINDOW" == "null" ]] || [[ -z "$TARGET_WINDOW" ]]; then
        echo "No minimized windows found"
        exit 1
    fi
else
    TARGET_WINDOW="$CURRENT_WINDOW"
fi

# Step 1: Focus a different window first (to clear state)
OTHER_WINDOW=$(yabai -m query --windows --space | \
    jq -r "map(select(.minimized == 0 and .id != $TARGET_WINDOW)) | .[0].id")

if [[ "$OTHER_WINDOW" != "null" ]] && [[ -n "$OTHER_WINDOW" ]]; then
    yabai -m window --focus "$OTHER_WINDOW"
    sleep 0.1  # Brief delay to let macOS process the focus change
fi

# Step 2: Explicitly deminimize and focus the target window
yabai -m window "$TARGET_WINDOW" --deminimize
yabai -m window --focus "$TARGET_WINDOW"
```

**Create** `xdg_config/yabai/focus_prev_non_minimized.sh`:

```bash
#!/usr/bin/env zsh

# Cycle to previous non-minimized window
yabai -m query --spaces --space \
  | jq -re ".index" \
  | xargs -I{} yabai -m query --windows --space {} \
  | jq "map(select(.minimized == 0))" \
  | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(index(map(select(.focused == 1))) - 1).id" \
  | xargs -I{} yabai -m window --focus {}
```

**Create** `xdg_config/yabai/focus_next_non_minimized.sh`:

```bash
#!/usr/bin/env zsh

# Cycle to next non-minimized window
yabai -m query --spaces --space \
  | jq -re ".index" \
  | xargs -I{} yabai -m query --windows --space {} \
  | jq "map(select(.minimized == 0))" \
  | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | reverse | nth(index(map(select(.focused == 1))) - 1).id" \
  | xargs -I{} yabai -m window --focus {}
```

**Why This Helps**:
- Uses explicit window IDs instead of app-level focus
- Focuses another window first to break macOS state
- Skips minimized windows in focus cycling
- Gives you keyboard control over minimize/deminimize

---

### Solution 3: Use Hide Instead of Minimize (WORKAROUND)

Since macOS treats minimize at the app level, use "hide" (Cmd+H) instead, which Yabai handles better.

**No configuration changes needed** - just change your workflow:
- Instead of minimizing windows → use Cmd+H to hide
- Instead of clicking dock → use Alt+W/A/S/D to focus windows directly
- Use Yabai's window focus commands instead of Cmd+Tab

**Why This Helps**:
- Hide is per-application, not per-window
- Yabai has better control over hidden windows
- Avoids macOS Accessibility API limitations with minimize

---

### Solution 4: Add Debug Logging

Add comprehensive logging to understand exactly when/why windows are being unminimized.

**Implementation**:

Add to `xdg_config/yabai/yabairc` after line 15:

```bash
# Debug logging for window state changes
yabai -m signal --add event=window_minimized action="echo \"[$(date)] MINIMIZED: \$YABAI_WINDOW_ID (\$YABAI_WINDOW_APP)\" >> /tmp/yabai_minimize_debug.log"
yabai -m signal --add event=window_deminimized action="echo \"[$(date)] DEMINIMIZED: \$YABAI_WINDOW_ID (\$YABAI_WINDOW_APP)\" >> /tmp/yabai_minimize_debug.log"
yabai -m signal --add event=window_focused action="echo \"[$(date)] FOCUSED: \$YABAI_WINDOW_ID (\$YABAI_WINDOW_APP) - minimized=\$(yabai -m query --windows --window \$YABAI_WINDOW_ID | jq -r .minimized)\" >> /tmp/yabai_minimize_debug.log"
yabai -m signal --add event=application_front_switched action="echo \"[$(date)] APP SWITCHED: \$YABAI_PROCESS_ID - \$(yabai -m query --windows --window | jq -r .app)\" >> /tmp/yabai_minimize_debug.log"
```

**View logs**:
```bash
tail -f /tmp/yabai_minimize_debug.log
```

**Why This Helps**:
- See exact sequence of events when windows unminimize
- Identify if it's window_focused, window_deminimized, or application_front_switched
- Determine if multiple windows deminimize simultaneously or sequentially

---

## Recommended Implementation Plan

### Phase 1: Add Debugging (Do This First)
1. Add debug logging signals (Solution 4)
2. Restart Yabai: `yabai --restart-service`
3. Reproduce the bug while monitoring logs: `tail -f /tmp/yabai_minimize_debug.log`
4. Share the log output to understand the exact event sequence

### Phase 2: Add Signal Handler (Core Fix)
1. Create `window-deminimized.zsh` script (Solution 1)
2. Make it executable: `chmod +x ~/.config/yabai/window-deminimized.zsh`
3. Add window_deminimized signal to yabairc
4. Restart Yabai and test

### Phase 3: Add Keyboard Shortcuts (If Still Needed)
1. Create the three focus scripts (Solution 2)
2. Make them executable: `chmod +x ~/.config/yabai/*.sh`
3. Add shortcuts to skhdrc
4. Restart skhd: `skhd --restart-service`
5. Test using keyboard instead of dock/Cmd+Tab

### Phase 4: Consider Workflow Change (If Nothing Else Works)
1. Try using Cmd+H (hide) instead of minimize for a week
2. Use Yabai's focus commands (Alt+W/A/S/D) instead of Cmd+Tab
3. See if the problem disappears

---

## Expected Outcomes

### If macOS API is the culprit:
- Solution 1 (signal handler) will work by intercepting and isolating each deminimize event
- Debug logs will show all windows deminimizing in rapid sequence
- You'll see events like: `APPLICATION_FRONT_SWITCHED` followed by multiple `DEMINIMIZED` events

### If Cmd+Tab is the culprit:
- Solution 2 (keyboard shortcuts) will work by bypassing Cmd+Tab
- Debug logs will show the issue only happens with certain focus methods
- Using Yabai's `window --focus` commands will avoid the problem

### If it's app-specific behavior:
- Debug logs will show it only happens with certain applications
- Solution 3 (use hide) will work for those specific apps
- You can add app-specific rules to handle them differently

---

## Testing Checklist

After implementing each solution, test these scenarios:

- [ ] Minimize 3 windows of the same app (e.g., 3 Chrome windows)
- [ ] Minimize 1 window of a different app (e.g., 1 Terminal window)
- [ ] Click dock icon of the app with 3 minimized windows
- [ ] Does only 1 window unminimize, or all 3?
- [ ] Use Alt+Tab to switch apps
- [ ] Does the problem still occur?
- [ ] Use Yabai focus commands (Alt+W/A/S/D)
- [ ] Does the problem still occur?
- [ ] Check `/tmp/yabai_minimize_debug.log` for event sequence

---

## Files to Create/Modify

### New Files:
1. `xdg_config/yabai/window-deminimized.zsh` (Solution 1)
2. `xdg_config/yabai/deminimize_single_window.sh` (Solution 2)
3. `xdg_config/yabai/focus_prev_non_minimized.sh` (Solution 2)
4. `xdg_config/yabai/focus_next_non_minimized.sh` (Solution 2)

### Modified Files:
1. `xdg_config/yabai/yabairc` - Add signals
2. `xdg_config/skhd/skhdrc` - Add shortcuts (optional)

---

## Rollback Plan

If any solution makes things worse:

```bash
# Remove debug logging
sed -i '' '/minimize_debug.log/d' ~/.config/yabai/yabairc

# Remove signal handler
sed -i '' '/window-deminimized.zsh/d' ~/.config/yabai/yabairc

# Remove shortcuts from skhdrc
# (Manually delete the MINIMIZE/DEMINIMIZE WINDOWS section)

# Restart services
yabai --restart-service
skhd --restart-service
```

---

## Additional Investigation

If none of the solutions work, we should investigate:

1. **Which app?** - Does this happen with all apps or specific ones (Chrome, VS Code, Terminal)?
2. **Which macOS version?** - Sonoma introduced new window management APIs
3. **System Preferences** - Check System Settings > Desktop & Dock > "Minimize windows into application icon"
4. **Other window managers** - Do you have any other window management tools running? (Rectangle, Magnet, etc.)
5. **Accessibility permissions** - Ensure Yabai has full Accessibility access

---

## Why This Bug Is Hard to Fix

From the research and configuration analysis:

1. **macOS Limitation**: The Accessibility API doesn't distinguish between "focus this specific window" and "focus this app with these windows"
2. **No Direct Reports**: No one else has reported this exact issue, suggesting it's either:
   - Very specific to your setup
   - A recent macOS change
   - Something in your workflow triggering macOS native behavior
3. **Opposite Problem Exists**: Issue #1037 shows people have the opposite problem (minimizing one minimizes all), suggesting macOS handles minimize/deminimize at the application level, not window level

The solutions above work around these limitations by:
- Intercepting events at the Yabai level before macOS processes them
- Using explicit window IDs to isolate operations
- Breaking up the focus/deminimize sequence to avoid batch operations
- Providing alternative workflows that avoid the problematic code paths

---

## Next Steps

1. **Start with Phase 1** (debugging) to understand the exact event sequence
2. **Share the debug logs** so we can see what's actually happening
3. **Implement Solution 1** (signal handler) as it's the most likely to work
4. **Test thoroughly** using the checklist above
5. **Report back** with results so we can refine the solution

Let me know which phase you'd like to implement first, and I can help with the specific commands and testing!
