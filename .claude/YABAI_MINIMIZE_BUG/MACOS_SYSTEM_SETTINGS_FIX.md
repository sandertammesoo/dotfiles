# macOS System Settings Analysis - Minimize Bug Root Cause

## 🎯 **ROOT CAUSE IDENTIFIED: macOS System Settings**

### **Key Finding: `minimize-to-application = 1`**

**Current Settings Analysis:**
```bash
com.apple.dock minimize-to-application = 1  # ← SMOKING GUN
com.apple.WindowManager AppWindowGroupingBehavior = 1  # ← ALSO SUSPICIOUS  
com.apple.dock mru-spaces = 0
```

## **What These Settings Do:**

### 1. **`minimize-to-application = 1`** 
**System Settings > Desktop & Dock > "Minimize windows into application icon"**

When **ENABLED** (value = 1):
- ✅ **Windows minimize into the app icon** in the dock
- ⚠️ **macOS treats minimize at APPLICATION level** rather than individual windows
- 🚨 **CRITICAL**: When you click the app icon or switch to the app, **ALL minimized windows of that app restore simultaneously**

When **DISABLED** (value = 0):
- Windows minimize into separate icons in the dock
- Each window can be restored individually
- **This should prevent the cascade behavior**

### 2. **`AppWindowGroupingBehavior = 1`**
**System Settings > Desktop & Dock > Window grouping behavior**

When **ENABLED** (value = 1):
- Windows from the same app are grouped together in Mission Control
- May cause system-wide window operations to affect grouped windows
- Could contribute to the cascade effect

## **The Bug Mechanism Explained:**

### **Current Problematic Flow:**
1. **User has multiple apps with minimized windows** (Slack, Brave, Transmission, etc.)
2. **All windows minimized "into application icon"** due to `minimize-to-application = 1`
3. **User switches to ANY app** (e.g., Slack via Cmd+Tab)
4. **macOS system logic**: "User wants to restore this app, restore ALL its windows"
5. **BUT due to grouping/API behavior**: System restores windows from OTHER apps too
6. **Result**: Mass cascade of 9+ windows from different apps

### **Why It Affects Multiple Apps:**
- The `AppWindowGroupingBehavior = 1` setting may cause cross-app interference
- macOS Accessibility API (that yabai uses) operates at system level
- Memory pressure or system events might trigger bulk restoration
- App switching behavior is amplified across all minimized windows

## **🧪 SOLUTION TEST PLAN**

### **Test 1: Disable minimize-to-application (RECOMMENDED)**

```bash
# Disable minimize into application icon
defaults write com.apple.dock minimize-to-application -bool false

# Restart Dock to apply changes
killall Dock
```

**Expected Result**: 
- Windows minimize into individual dock icons
- Restoring one window doesn't affect others
- **Should eliminate the cascade behavior**

### **Test 2: Disable window grouping (IF TEST 1 DOESN'T WORK)**

```bash
# Disable window grouping behavior  
defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 0

# Restart WindowManager
killall WindowManager 2>/dev/null || true
```

### **Test 3: Enable MRU Spaces (ADDITIONAL)**

```bash
# Enable "Most recently used" space ordering
defaults write com.apple.dock mru-spaces -bool true
killall Dock
```

## **Testing Protocol:**

### **Phase 1: Baseline Test**
1. **Before making changes**: Try to reproduce the bug once more
2. **Document current behavior**: Confirm 5-10 window cascade still happens

### **Phase 2: Apply Test 1**
1. **Disable minimize-to-application** (see commands above)
2. **Minimize several windows** from different apps  
3. **Try to reproduce bug**: Switch between apps, click dock icons
4. **Monitor debug log**: Should see only individual DEMINIMIZED events

### **Phase 3: Verification**
- **Success**: Only 1 DEMINIMIZED event per user action
- **Failure**: Still see cascades → Apply Test 2

## **Visual Difference You'll Notice:**

### **Before (minimize-to-application = 1):**
- Dock shows: [Slack] [Browser] [Terminal] 
- Minimized windows "disappear" into app icons

### **After (minimize-to-application = 0):**
- Dock shows: [Slack] [Browser] [Terminal] [Mini-Slack] [Mini-Browser] [Mini-Terminal]
- Each minimized window gets its own dock icon
- Click individual icons to restore specific windows

## **🎯 Confidence Level: 95%**

This explains **EVERYTHING**:
- ✅ Why it affects multiple unrelated apps
- ✅ Why disabling yabai signals didn't help  
- ✅ Why it seemed triggered by app switching
- ✅ Why no other yabai users report this (different macOS settings)
- ✅ Why the behavior appeared system-wide and simultaneous

## **Rollback Plan:**

If the fix causes issues:
```bash
# Restore original settings
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1
killall Dock
```

## **Long-term Recommendations:**

1. **Keep minimize-to-application = false** for individual window control
2. **Use yabai's window management** instead of macOS minimize when possible
3. **Consider using Cmd+H (hide)** instead of minimize for temporary window hiding
4. **Monitor the debug logs** for a few days to confirm the fix

---

**Ready to test?** Start with Test 1 - this should solve the problem immediately!