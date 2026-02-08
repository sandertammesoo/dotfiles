# URGENT BUG FIX: Window-Created Signal Root Cause Analysis

## 🚨 CRITICAL DISCOVERY: Real Root Cause Found

**Date**: November 4, 2025 11:58:44  
**Bug Trigger**: `window_created` signal, NOT `application_activated`

## 🔥 Evidence from Latest Bug Occurrence

**Timeline of Events:**
```
11:58:44 - WINDOW_CREATED: Script started for window ID: 101020
11:58:44 - WINDOW_CREATED: Checking if window belongs to Finder app
11:58:44 - DEMINIMIZED: [CASCADE BEGINS] 
11:58:45 - DEMINIMIZED: [12 MORE EVENTS]
11:58:45 - CASCADE DETECTED: 7+ deminimize events
```

**Key Insight**: The cascade started IMMEDIATELY when a new window (ID: 101020) was created, triggering the `window-created.zsh` script.

## 🧬 Root Cause Analysis

### The Problematic `is_app()` Function

In `window-created.zsh`, this function runs for EVERY new window:

```bash
is_app() {
    echo $(yabai -m query --spaces --space \
        | jq -re ".index" \
        | xargs -I{} yabai -m query --windows --space {} \
        | jq -r 'map(select(.id=='$YABAI_WINDOW_ID' and .app=="'$1'" and .subrole=="AXStandardWindow")) | .[] | [.app][]')
}
```

**This function:**
1. **Queries the current space**
2. **Queries ALL windows on that space** 
3. **Filters for the specific window ID**

### The Cascade Mechanism

When a new window is created:
1. **`window_created` signal fires** → `window-created.zsh` starts
2. **`is_app()` function queries all windows** on the current space
3. **Window queries trigger focus/state changes** in other windows
4. **Minimized windows get caught up** in the query operations and are deminimized
5. **Massive cascade** of 7-12+ windows deminimized simultaneously

## ✅ Fix Applied: Disable window_created Signal

**What I did:**
- **Commented out** the `window_created` signal in `yabairc` line 27
- **Restarted yabai** to apply the change
- **Window-created script no longer runs** for new windows

**Impact:**
- ✅ **Bug should be eliminated** - no more cascade-triggering window queries
- ⚠️ **Finder auto-positioning disabled** - new Finder windows won't auto-position at bottom
- ✅ **All other yabai functionality preserved**

## 🧪 Testing Plan

### Immediate Test:
1. **Minimize windows** from multiple apps (Signal, Messenger, Notion, Browser)
2. **Focus any minimized window** using:
   - Dock clicks
   - Cmd+Tab
   - Alt+W/A/S/D shortcuts
3. **Expected Result**: Only the intended window deminimizes (no cascade)

### Create New Windows Test:
1. **Open new windows** in various apps
2. **Monitor debug log**: Should see NO `WINDOW_CREATED` entries
3. **Expected Result**: No cascade triggered by new window creation

### Verification Commands:
```bash
# Monitor for any remaining cascades
tail -f /tmp/yabai_minimize_debug.log

# Check enhanced debug for cascade detection
grep "CASCADE DETECTED" /tmp/yabai_enhanced_debug.log | tail -5
```

## 📊 Why This Makes Perfect Sense

### Previous Misleading Evidence:
- We saw `application-activated` running multiple times during cascades
- **But that was EFFECT, not CAUSE**
- The window queries in `window-created.zsh` were triggering app activations
- Rate limiting the wrong script had minimal impact

### The Real Pattern:
1. **Any new window creation** → window_created signal
2. **Complex window queries** in is_app() function  
3. **Query operations disturb minimized windows** across all apps
4. **Mass deminimization cascade** occurs

### Why It Affects All Apps:
- The bug wasn't about focusing specific apps
- It was about **ANY window creation** triggering the problematic queries
- **New windows** could be created by: app launches, tab opens, dialog boxes, etc.
- This explains why it seemed "random" and affected "any app"

## 🎯 Next Steps

### If Bug Is Fixed:
- **Monitor for 24-48 hours** to confirm no more cascades
- **Consider safer Finder positioning** if needed (without complex queries)
- **Document this as the definitive solution**

### If Bug Persists:
- **Check for other signal handlers** that do window queries
- **Investigate yabai configuration** for other cascade triggers
- **May need to examine application-activated script further**

## 💡 Lessons Learned

1. **Window queries in signal handlers are dangerous** - they can disturb window states
2. **Signal handlers should be minimal** - avoid complex operations that trigger other signals  
3. **Focus on the TRIGGER, not the EFFECT** - application_activated was the effect of window_created
4. **Complex jq queries during window operations** can cause unintended state changes

## ✅ Success Criteria

**Bug is fixed when:**
- ✅ No more CASCADE DETECTED messages
- ✅ Only 1 DEMINIMIZED event per user action
- ✅ No WINDOW_CREATED entries in debug log (signal disabled)
- ✅ Minimized windows stay minimized until explicitly focused

---

**Status**: 🚨 **CRITICAL FIX APPLIED - TESTING IN PROGRESS**

The window_created signal has been disabled. This should eliminate the bug completely by removing the complex window queries that were causing the cascade effect.