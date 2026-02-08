# Testing Plan: Yabai Minimize Bug Fix - Rate Limiting Solution

## ✅ Fix Applied: Rate Limiting for application-activated.zsh

**What Changed:**
1. **Added lock file mechanism** to prevent script from running more than once per 2 seconds
2. **Rate limiting protection** - script exits immediately if run within 2 seconds of last execution
3. **Lock file cleanup** on successful completion

## 🧪 Testing Instructions

### Phase 1: Test the Rate Limiting Fix

**Setup:**
1. Clear debug log: `~/.config/yabai/debug_minimize.sh clear`
2. Monitor in real-time: `~/.config/yabai/debug_minimize.sh tail`

**Test Scenarios:**
1. **Signal/Messenger Test:**
   - Minimize a Signal window
   - Minimize a Messenger window  
   - Use dock/Cmd+Tab to focus the Signal window
   - **Expected**: Only Signal window deminimizes
   - **Previous bug**: All minimized windows would deminimize

2. **Browser Windows Test:**
   - Minimize 2-3 browser windows (different tabs/windows)
   - Minimize a Notion window
   - Focus one of the browser windows
   - **Expected**: Only the focused browser window deminimizes

3. **Multiple Apps Test:**
   - Have minimized windows from: Slack, Signal, Notion, Browser, VS Code
   - Focus any one of them using various methods:
     - Dock click
     - Cmd+Tab
     - Alt+W/A/S/D (yabai shortcuts)
   - **Expected**: Only the intended window deminimizes

**What to Watch For:**
- In the debug log, look for:
  ```
  APP_ACTIVATED: Script skipped - rate limited (last run Xs ago)
  ```
- This indicates the fix is working - preventing cascade executions

### Phase 2: If Rate Limiting Doesn't Fix It

If you still see cascades, we can test the minimal script:

**Switch to minimal handler:**
1. Edit `~/.config/yabai/yabairc` line 24:
   ```bash
   # Change from:
   yabai -m signal --add event=application_activated action="zsh ~/.config/yabai/application-activated.zsh"
   
   # To:
   yabai -m signal --add event=application_activated action="zsh ~/.config/yabai/minimal-application-activated.zsh"
   ```
2. Restart yabai: `yabai --restart-service`
3. Test if bug still occurs with minimal script

**This will tell us:**
- If bug disappears → The issue is in the window stacking logic
- If bug persists → The issue is deeper in yabai's signal handling or macOS

## 🔍 Monitoring Commands

```bash
# Real-time monitoring
~/.config/yabai/debug_minimize.sh tail

# Check for rate limiting messages
grep "rate limited" /tmp/yabai_minimize_debug.log

# Count cascade events (should be 0 with fix)
grep -A1 -B1 "CASCADE DETECTED" /tmp/yabai_enhanced_debug.log

# Check application-activated frequency
grep "APP_ACTIVATED" /tmp/yabai_minimize_debug.log | tail -20
```

## 🎯 Expected Results

**With Rate Limiting Fix:**
- **Normal operation**: Single "APP_ACTIVATED: Script started" per app focus
- **Cascade prevention**: "APP_ACTIVATED: Script skipped - rate limited" messages
- **No more mass deminimize**: Only intended window deminimizes

**Success Criteria:**
- ✅ No more than 1 DEMINIMIZED event per user action
- ✅ Rate limiting messages appear in log during rapid app switching  
- ✅ Enhanced debug shows no CASCADE DETECTED events
- ✅ Application-activated script runs maximum once per 2 seconds

## 🚨 If Problem Persists

If rate limiting doesn't solve it, next steps:
1. **Disable application_activated entirely** (comment out line 24 in yabairc)
2. **Test window management without auto-stacking**
3. **Isolate if it's the window queries or stacking operations causing cascades**

## 📊 Root Cause Analysis Summary

**Original Problem:**
- `application-activated.zsh` script ran 12+ times in 2 seconds
- Each execution queries all windows on current space
- Window queries trigger additional focus/activation events
- Creates feedback loop causing cascade deminimization

**Solution:**
- Rate limiting prevents script from running more than once per 2 seconds
- Breaks the cascade feedback loop
- Maintains auto-stacking functionality while preventing bug

Let me know the results of your testing!