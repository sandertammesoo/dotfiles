# Phase 1 Debug Implementation - Quick Reference

## ✅ What Was Implemented

1. **Added debug signals to yabairc** (lines 17-20):
   - `window_minimized` - Logs when a window is minimized
   - `window_deminimized` - Logs when a window is unminimized
   - `window_focused` - Logs when a window receives focus (with minimize state)
   - `application_front_switched` - Logs when you switch apps

2. **Created debug helper script**: `~/.config/yabai/debug_minimize.sh`
   - Provides easy commands to monitor and analyze the log

3. **Fixed deprecated field names**:
   - Changed `minimized` → `"is-minimized"` in yabairc
   - Changed `.minimized==0` → `.["is-minimized"]==false` in application-activated.zsh
   - Changed `.floating==0` → `.["is-floating"]==false` in application-activated.zsh
   - Updated debug script to use correct field names

4. **Restarted Yabai** to activate the logging

---

## ⚠️ Important: Field Name Fix

**Discovery**: The configuration was using deprecated Yabai field names that returned `null` values.

**Before Fix**: `minimized=null` (couldn't detect minimize state)  
**After Fix**: `is-minimized=true` or `is-minimized=false` (works correctly)

This fix was critical because without it, Yabai couldn't track which windows were minimized, making debugging impossible.

---

## 🔍 How to Reproduce and Debug

### Step 1: Clear the log and start fresh
```bash
~/.config/yabai/debug_minimize.sh clear
```

### Step 2: Set up your test scenario
1. Open several applications (e.g., Chrome, Terminal, VS Code, Finder)
2. Open multiple windows in each app
3. Minimize at least 2-3 windows from DIFFERENT apps
4. Leave at least one window visible and focused

### Step 3: Start monitoring in a separate terminal
```bash
~/.config/yabai/debug_minimize.sh tail
```

### Step 4: Trigger the bug
Choose one method:
- **Option A**: Click on a minimized window in the Dock
- **Option B**: Use Cmd+Tab to switch to an app with a minimized window
- **Option C**: Click on a window title in the menu bar (if minimized)

### Step 5: Watch the log output
You should see something like:
```
[2025-10-18 20:30:15] APP SWITCHED: 1234 - Chrome
[2025-10-18 20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[2025-10-18 20:30:15] DEMINIMIZED: 9877 (Terminal)        ← ⚠️ UNEXPECTED!
[2025-10-18 20:30:15] DEMINIMIZED: 9878 (Visual Studio Code)  ← ⚠️ UNEXPECTED!
[2025-10-18 20:30:15] FOCUSED: 9876 (Google Chrome) - minimized=0
```

---

## 📊 Analyze the Results

### View event summary
```bash
~/.config/yabai/debug_minimize.sh count
```

### View all events
```bash
~/.config/yabai/debug_minimize.sh show
```

### See currently minimized windows
```bash
~/.config/yabai/debug_minimize.sh apps
```

---

## 🎯 What to Look For

### Scenario A: Multiple DEMINIMIZED events in quick succession
```
[2025-10-18 20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[2025-10-18 20:30:15] DEMINIMIZED: 9877 (Terminal)
[2025-10-18 20:30:15] DEMINIMIZED: 9878 (Visual Studio Code)
```
**This means**: ALL windows are being deminimized at the same time by macOS or a signal

### Scenario B: APP SWITCHED followed by cascade
```
[2025-10-18 20:30:15] APP SWITCHED: 1234 - Chrome
[2025-10-18 20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[2025-10-18 20:30:15] FOCUSED: 9876 (Google Chrome) - is-minimized=false
[2025-10-18 20:30:16] DEMINIMIZED: 9877 (Terminal)
[2025-10-18 20:30:16] DEMINIMIZED: 9878 (Visual Studio Code)
```
**This means**: The focus event might be triggering other windows to deminimize

### Scenario C: FOCUSED events causing chain reaction
```
[2025-10-18 20:30:15] FOCUSED: 9876 (Google Chrome) - is-minimized=true
[2025-10-18 20:30:15] DEMINIMIZED: 9876 (Google Chrome)
[2025-10-18 20:30:15] DEMINIMIZED: 9877 (Terminal)
```
**This means**: The window_focused signal might be interfering

**Note**: Before the field name fix, these logs showed `minimized=null` which made debugging impossible. Now you'll see accurate `is-minimized=true` or `is-minimized=false` values.

---

## 🧪 Additional Tests

### Test 1: Does it happen with all apps?
1. Clear log
2. Minimize only Chrome windows, focus one
3. Check if other app windows deminimize

### Test 2: Does it happen with keyboard shortcuts only?
1. Clear log
2. Don't use dock or Cmd+Tab
3. Use only Yabai shortcuts: `Alt+W/A/S/D`
4. See if bug still occurs

### Test 3: Does disabling sketchybar signals help?
1. Comment out the sketchybar signals in yabairc:
   ```bash
   # yabai -m signal --add event="window_focused" action="sketchybar -m --trigger window_focus &> /dev/null"
   ```
2. Restart Yabai
3. Test if bug still occurs

---

## 🚨 Key Questions to Answer

1. **How many DEMINIMIZED events occur?**
   - Just 1? (Expected behavior)
   - 2-3? (Same app only)
   - 5+? (All apps - the bug!)

2. **What's the time gap between events?**
   - All at once (same timestamp)? → macOS batch operation
   - Milliseconds apart? → Cascade from signal handlers
   - Seconds apart? → Something else triggering

3. **Does the order matter?**
   - Are they deminimized in space order?
   - In window ID order?
   - Random?

4. **Which event triggers it?**
   - APP SWITCHED?
   - First DEMINIMIZED?
   - FOCUSED?

---

## 📝 Report Back

After running the tests, share:

1. **The raw log output** from reproducing the bug once
2. **The count summary** (`debug_minimize.sh count`)
3. **Which trigger method** causes it (dock click, Cmd+Tab, etc.)
4. **Whether Test 3** (disabling sketchybar signals) made any difference

This will tell us exactly what's happening and whether it's:
- ❌ macOS system behavior (unfixable)
- ⚠️ Signal handler interference (fixable)
- 🔧 Configuration issue (fixable)
- 🐛 Yabai bug (report to maintainer)

---

## 🛠️ Quick Commands Reference

```bash
# Monitor log in real-time
~/.config/yabai/debug_minimize.sh tail

# Clear and start fresh
~/.config/yabai/debug_minimize.sh clear

# Show statistics
~/.config/yabai/debug_minimize.sh count

# Show all events
~/.config/yabai/debug_minimize.sh show

# Show minimized windows
~/.config/yabai/debug_minimize.sh apps

# View raw log file
cat /tmp/yabai_minimize_debug.log

# Restart Yabai
yabai --restart-service
```

---

## Next Steps

Once you've gathered the debug data:
1. Share the log output here
2. I'll analyze the event sequence
3. We'll implement the appropriate fix from Phase 2-4
4. The fix will be targeted to the specific cause we identified
