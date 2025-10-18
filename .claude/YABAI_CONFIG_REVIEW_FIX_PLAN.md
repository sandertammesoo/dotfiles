# Yabai Configuration Review & Fix Plan

**Review Date:** October 18, 2025  
**Reviewer:** GitHub Copilot  
**Configuration Location:** 
- Main Config: `xdg_config/yabai/`
- Bootstrap: `zsh-setup-scripts/yabai/`

---

## Executive Summary

Your Yabai configuration is well-structured with proper scripting addition setup and comprehensive window management rules. However, there are several bugs, redundancies, and areas for improvement that should be addressed to ensure reliable operation across different display configurations and macOS versions.

**Overall Status:** 🟡 Good foundation with notable issues requiring fixes

---

## Detailed Findings

### ✅ Strengths

1. **Proper Scripting Addition Setup**
   - Hash-based sudoers configuration in `bootstrap.sh`
   - Automatic hash updates on version changes
   - Proper permissions (440) on sudoers file

2. **Comprehensive Window Rules**
   - Extensive list of 30+ applications configured as floating windows
   - System utilities properly excluded from tiling
   - Good coverage of common macOS apps

3. **Sketchybar Integration**
   - Proper signals for `window_focused` and `window_title_changed`
   - Dock restart handler configured
   - Integration with borders utility

4. **Multi-Display Support**
   - Display lookup tables (LUT) for 1-4 display configurations
   - Dynamic space-to-display assignment
   - Separate home and work setups

5. **Consistent Settings**
   - Reasonable defaults for padding (4px) and gaps (4px)
   - External bar compensation configured (37px bottom)
   - Window opacity disabled for performance

### ⚠️ Critical Issues

#### 1. **Bug in `move_application_to_space.sh`**
**Severity:** 🔴 High  
**Location:** Line 50

```bash
# WRONG - $id is a window ID, not a space number
yabai -m space --focus $id

# Should be:
yabai -m space --focus $space
```

**Impact:** Script will fail or focus wrong space after moving windows.

#### 2. **Duplicate Rules in `yabairc`**
**Severity:** 🟡 Medium  
**Locations:** Lines 36 and 52

```bash
yabai -m rule --add app="^Finder$" manage=off  # Line 36
# ... other rules ...
yabai -m rule --add app="^Finder$" manage=off  # Line 52 (duplicate)
```

**Impact:** Redundant, wastes processing time, confusing for maintenance.

#### 3. **Typo in Application Name**
**Severity:** 🟡 Medium  
**Location:** Line 50

```bash
yabai -m rule --add app="^DBeave$" manage=off  # Should be DBeaver?
```

**Impact:** Rule won't match intended application.

#### 4. **Hardcoded Window Positioning**
**Severity:** 🟡 Medium  
**File:** `window-created.zsh`

```bash
yabai -m window --move abs:0:709
yabai -m window --resize abs:1500:730
```

**Impact:** 
- Won't work correctly on different display resolutions
- Breaks on multi-monitor setups
- Not portable across different machines

### ⚠️ Design Issues

#### 5. **Redundant Function Calls**
**Severity:** 🟢 Low  
**Files:** `space_setup_home.sh`, `space_setup_work.sh`

```bash
run_setup_spaces
run_setup_spaces  # Why run twice?
```

**Impact:** Doubles execution time, may cause race conditions.

#### 6. **Missing Error Handling**
**Severity:** 🟡 Medium  
**Files:** Multiple scripts

```bash
# No validation if jq parsing succeeds
window_ids=$(echo $app_windows | jq -r "select(.app == \"$app\") | .ids[]")

# No check if window/space exists before operations
yabai -m window $id --space $space
```

**Impact:** Silent failures, difficult to debug issues.

#### 7. **Inconsistent Display LUTs**
**Severity:** 🟢 Low  
**Files:** `space_setup_home.sh` vs `space_setup_work.sh`

```bash
# Home (3 displays):
"1 1 1 1 1 2 2 3 3"

# Work (3 displays):
"1 1 1 1 2 2 3 3 3"
```

**Impact:** Different behavior between environments, potential confusion.

#### 8. **Rules Added After Window Movement**
**Severity:** 🟢 Low  
**Files:** Space setup scripts

Rules are added at the end after moving windows. Should be added before to affect new windows immediately.

#### 9. **Commented-Out Signals**
**Severity:** 🟢 Low  
**File:** `yabairc` lines 104-105

```bash
#yabai -m signal --add event=application_activated action="zsh ~/.config/yabai/application-activated.zsh"
#yabai -m signal --add event=window_created action="zsh ~/.config/yabai/window-created.zsh"
```

**Impact:** Dead code, unclear if intentionally disabled or forgotten.

### 📋 Compliance with Yabai Documentation

Based on the official Yabai reference documentation:

✅ **Correct Usage:**
- Scripting addition setup follows documentation
- Signal syntax is correct
- Config options use valid values
- Query commands properly formatted
- Rule syntax is correct

⚠️ **SIP Requirements:**
Your configuration uses features that require SIP to be partially disabled:
- `window_opacity` (currently disabled but configured)
- `window_shadow`
- `active_window_opacity` / `normal_window_opacity`
- `--space` command for windows (on macOS Monterey 12.7+, Ventura 13.6+, Sonoma 14.5+, Sequoia)
- Borders utility features

**Recommendation:** Document SIP status and requirements in README.

### 🔍 Additional Observations

1. **Performance Optimization:**
   - `window_animation_duration` set to 0.0 (good for performance)
   - `window_opacity` disabled (good for performance)
   - `auto_balance` disabled (prevents constant rebalancing)

2. **Mouse Interaction:**
   - Uses `fn` key as modifier (less common, usually `alt` or `cmd`)
   - `mouse_follows_focus` disabled (personal preference)
   - `focus_follows_mouse` disabled (prevents accidental focus changes)

3. **Space Management:**
   - Fixed 9-space setup
   - Apps assigned to specific spaces
   - Different layouts for home vs work

---

## Action Plan

### Phase 1: Critical Fixes (Priority: 🔴 High)

#### Task 1.1: Fix Bug in `move_application_to_space.sh`
**File:** `xdg_config/yabai/move_application_to_space.sh`

```bash
# Line 50: Change from
yabai -m space --focus $id

# To
yabai -m space --focus $space
```

**Estimated Time:** 2 minutes  
**Testing:** Move an app to different space and verify correct space is focused

---

#### Task 1.2: Remove Duplicate Finder Rule
**File:** `xdg_config/yabai/yabairc`

```bash
# Remove the duplicate at line 52
# Keep only the first instance at line 36
```

**Estimated Time:** 1 minute  
**Testing:** Verify Finder still floats after restart

---

#### Task 1.3: Fix DBeaver Typo
**File:** `xdg_config/yabai/yabairc`

```bash
# Line 50: Change from
yabai -m rule --add app="^DBeave$" manage=off

# To
yabai -m rule --add app="^DBeaver$" manage=off
```

**Estimated Time:** 1 minute  
**Testing:** If you use DBeaver, verify it floats correctly

---

### Phase 2: Improve Reliability (Priority: 🟡 Medium)

#### Task 2.1: Fix Hardcoded Window Positioning
**File:** `xdg_config/yabai/window-created.zsh`

**Option A: Use Grid-Based Positioning (Recommended)**
```bash
if [[ $(is_app "Finder") == "Finder" ]]; then
    yabai -m window --focus $YABAI_WINDOW_ID \
        & yabai -m window --grid 20:30:0:14:20:6
    # Grid: 20 rows, 30 cols, start at (0,14), span 20 cols x 6 rows
fi
```

**Option B: Dynamic Positioning Based on Display**
```bash
if [[ $(is_app "Finder") == "Finder" ]]; then
    # Get display dimensions
    local display_height=$(yabai -m query --displays --display | jq '.frame.h')
    local display_width=$(yabai -m query --displays --display | jq '.frame.w')
    
    # Calculate position (bottom of screen)
    local y_pos=$(($display_height - 730 - 50))
    
    yabai -m window --focus $YABAI_WINDOW_ID \
        & yabai -m window --move abs:0:$y_pos \
        & yabai -m window --resize abs:1500:730
fi
```

**Estimated Time:** 15 minutes  
**Testing:** Test on different display resolutions and multi-monitor setups

---

#### Task 2.2: Add Error Handling to Scripts
**Files:** All space setup and window management scripts

**Create Validation Functions:**
```bash
# Add to beginning of scripts

validate_window_exists() {
    local window_id="$1"
    if ! yabai -m query --windows --window "$window_id" &>/dev/null; then
        echo "Error: Window $window_id does not exist" >&2
        return 1
    fi
    return 0
}

validate_space_exists() {
    local space_id="$1"
    if ! yabai -m query --spaces --space "$space_id" &>/dev/null; then
        echo "Error: Space $space_id does not exist" >&2
        return 1
    fi
    return 0
}

safe_jq() {
    local result
    result=$(echo "$1" | jq -r "$2" 2>/dev/null)
    if [[ $? -ne 0 ]] || [[ -z "$result" ]] || [[ "$result" == "null" ]]; then
        echo "Error: jq parsing failed for query: $2" >&2
        return 1
    fi
    echo "$result"
    return 0
}
```

**Update Window Movement:**
```bash
# Before
yabai -m window $id --space $space

# After
if validate_window_exists "$id" && validate_space_exists "$space"; then
    if yabai -m window "$id" --space "$space" 2>/dev/null; then
        echo "Successfully moved window $id to space $space"
    else
        echo "Warning: Failed to move window $id to space $space" >&2
    fi
fi
```

**Estimated Time:** 1 hour  
**Testing:** Run scripts with missing windows/spaces, verify graceful failures

---

#### Task 2.3: Remove Redundant Function Calls
**Files:** `space_setup_home.sh`, `space_setup_work.sh`

```bash
# Change from
run_setup_spaces
run_setup_spaces  # Remove this duplicate
sketchybar --reload

# To
run_setup_spaces
sketchybar --reload
```

**Estimated Time:** 2 minutes  
**Testing:** Verify spaces still set up correctly after change

---

### Phase 3: Code Quality (Priority: 🟢 Low)

#### Task 3.1: Reorder Rules in Setup Scripts
**Files:** `space_setup_home.sh`, `space_setup_work.sh`

Move the rule additions to BEFORE the window movement section:

```bash
# Add rules first (before moving windows)
yabai -m rule --add app="^Spotify$" space=^9
yabai -m rule --add app="^Notion$" space=^2
# ... other rules ...

# Then move existing windows
echo "Moving apps between spaces..."
# ... window movement code ...
```

**Estimated Time:** 5 minutes  
**Testing:** Restart yabai and verify new windows go to correct spaces

---

#### Task 3.2: Clean Up Commented Code
**File:** `yabairc`

**Decision needed:** Either enable these signals or remove them:
```bash
# Lines 104-105
#yabai -m signal --add event=application_activated action="zsh ~/.config/yabai/application-activated.zsh"
#yabai -m signal --add event=window_created action="zsh ~/.config/yabai/window-created.zsh"
```

**If keeping disabled:** Add comment explaining why:
```bash
# Disabled: application-activated signal causes issues with X
# Disabled: window-created signal handled differently via Y
```

**Estimated Time:** 5 minutes  
**Testing:** N/A (documentation only)

---

#### Task 3.3: Standardize Display LUTs
**Files:** `space_setup_home.sh`, `space_setup_work.sh`

Document the rationale for different LUTs or standardize them:

```bash
# Home Setup (3 displays): Spaces distributed evenly
# Display 1: Spaces 1-5
# Display 2: Spaces 6-7  
# Display 3: Spaces 8-9
local display_LUT=("1 1 1 1 1 1 1 1 1" "1 1 1 1 2 2 2 2 2" "1 1 1 1 1 2 2 3 3" "1 1 1 2 2 2 3 3 4")

# Work Setup (3 displays): Different distribution for work focus
# Display 1: Spaces 1-4
# Display 2: Spaces 5-6
# Display 3: Spaces 7-9
local display_LUT=("1 1 1 1 1 1 1 1 1" "1 1 1 1 2 2 2 2 2" "1 1 1 1 2 2 3 3 3" "1 1 1 2 2 2 3 3 4")
```

**Estimated Time:** 10 minutes  
**Testing:** Verify space distribution matches expectations on each display

---

### Phase 4: Documentation & Maintenance (Priority: 🟢 Low)

#### Task 4.1: Create Yabai Directory README
**File:** `xdg_config/yabai/README.md`

**Content:**
```markdown
# Yabai Configuration

## System Requirements

- macOS 12.0+
- Yabai installed via Homebrew
- Borders utility (optional, for window borders)
- System Integrity Protection (SIP) partially disabled

## SIP Configuration

The following features require SIP to be partially disabled:

- Window opacity control
- Window shadow control
- Window space movement (macOS 12.7+, 13.6+, 14.5+, 15+)
- Borders utility features

To check SIP status: `csrutil status`

See: https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection

## Files

- `yabairc` - Main configuration file
- `application-activated.zsh` - Auto-stacking logic for windows
- `window-created.zsh` - Auto-positioning for specific apps
- `space_setup_home.sh` - 9-space setup for home configuration
- `space_setup_work.sh` - 9-space setup for work configuration
- `space_cycle_*.sh` - Space navigation helpers
- `move_*.sh` - Window/space movement utilities

## Space Layouts

### Home Setup (3 displays)
- Spaces 1-5: Display 1
- Spaces 6-7: Display 2
- Spaces 8-9: Display 3

### Work Setup (3 displays)
- Spaces 1-4: Display 1
- Spaces 5-6: Display 2
- Spaces 7-9: Display 3

## Managed Applications

The following apps are automatically assigned to specific spaces:

**Home:**
- Notion → Space 2
- Figma → Space 4
- Warp → Space 5
- Messenger, Signal, Keymapp, Reminders → Space 6
- Slack → Space 7
- Spotify → Space 9

**Work:**
- Figma → Space 3
- Warp → Space 4
- Messenger, Signal → Space 5
- Spotify, Keymapp → Space 6
- Notion → Space 9

## Unmanaged (Floating) Applications

30+ applications are configured to float instead of tile, including:
System Settings, Calculator, Finder, Activity Monitor, and various utilities.

## Troubleshooting

Logs are written to: `/tmp/yabai_${USER}.out.log`

Common issues:
- Windows not moving: Check SIP status
- Spaces not created: Check display count
- Rules not applying: Restart yabai service
```

**Estimated Time:** 30 minutes

---

#### Task 4.2: Add Debug Mode
**Files:** All scripts

Add debug flag support:

```bash
# At top of scripts
DEBUG=${YABAI_DEBUG:-0}

debug_log() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Usage
debug_log "Processing window $id for app $app"
```

**Enable with:** `YABAI_DEBUG=1 ./space_setup_home.sh`

**Estimated Time:** 20 minutes

---

#### Task 4.3: Create Testing Checklist
**File:** `xdg_config/yabai/TESTING.md`

```markdown
# Yabai Testing Checklist

## After Configuration Changes

- [ ] Restart yabai: `yabai --restart-service`
- [ ] Check logs: `tail -f /tmp/yabai_${USER}.out.log`
- [ ] Verify no errors in system logs

## Window Management
- [ ] Open Finder - should float
- [ ] Open Terminal - should tile
- [ ] Create new window - should tile correctly
- [ ] Move window between spaces
- [ ] Stack windows (if using stacking)

## Space Management
- [ ] Cycle through spaces (forward/back)
- [ ] Move window to next/prev space
- [ ] Create new space
- [ ] Destroy empty space

## Multi-Display
- [ ] Move window between displays
- [ ] Verify space assignments correct per display
- [ ] Test with 1, 2, 3+ displays

## Rules
- [ ] Launch managed apps - should go to correct space
- [ ] Launch unmanaged apps - should float
- [ ] Test with fresh yabai start

## Signals
- [ ] Window focus updates sketchybar
- [ ] Window title changes update sketchybar
- [ ] Borders highlight focused window
```

**Estimated Time:** 15 minutes

---

## Implementation Schedule

### Week 1: Critical Fixes
- **Day 1:** Tasks 1.1, 1.2, 1.3 (Critical bug fixes)
- **Day 2:** Task 2.1 (Fix hardcoded positioning)
- **Day 3:** Testing and verification

### Week 2: Reliability Improvements
- **Day 1-2:** Task 2.2 (Error handling)
- **Day 3:** Task 2.3 (Remove redundancies)
- **Day 4:** Testing

### Week 3: Polish & Documentation
- **Day 1:** Tasks 3.1, 3.2, 3.3 (Code quality)
- **Day 2-3:** Tasks 4.1, 4.2, 4.3 (Documentation)
- **Day 4:** Final testing and documentation review

---

## Testing Strategy

### Unit Testing
Each script should be tested individually:
```bash
# Test space setup
./space_setup_home.sh
# Verify 9 spaces created
yabai -m query --spaces | jq 'length'

# Test window movement
./move_application_to_space.sh 5
# Verify window moved to space 5
```

### Integration Testing
Test complete workflows:
1. Fresh yabai start
2. Run space setup script
3. Launch test applications
4. Verify rules apply correctly
5. Test keyboard shortcuts (from skhd)

### Regression Testing
After each change:
1. Restart yabai
2. Check logs for errors
3. Run through testing checklist
4. Verify existing functionality unchanged

---

## Rollback Plan

Before making changes:
```bash
# Backup current configuration
cd ~/projects/dotfiles
git checkout -b yabai-fixes-backup
git add xdg_config/yabai zsh-setup-scripts/yabai
git commit -m "Backup before yabai fixes"
```

If issues occur:
```bash
# Restore previous version
git checkout sander
git restore xdg_config/yabai zsh-setup-scripts/yabai
yabai --restart-service
```

---

## Success Criteria

- [ ] All critical bugs fixed
- [ ] No duplicate rules or code
- [ ] Scripts handle errors gracefully
- [ ] Configuration works across different display setups
- [ ] All features documented
- [ ] Testing checklist completed successfully
- [ ] No regressions in existing functionality

---

## Notes

- Monitor macOS updates for SIP requirement changes
- Consider adding yabai version check in bootstrap
- May want to consolidate home/work setup into one script with profiles
- Consider adding shell completion for custom scripts
- Borders configuration could be moved to dedicated config file

---

## References

- [Yabai Official Documentation](https://github.com/koekeishiya/yabai/wiki)
- [Yabai Reference Manual](YABAI_REFERENCE.md)
- [SIP Disabling Guide](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
- [Borders Utility](https://github.com/FelixKratz/JankyBorders)

---

**Last Updated:** October 18, 2025  
**Next Review:** Check after major macOS updates or yabai version changes
