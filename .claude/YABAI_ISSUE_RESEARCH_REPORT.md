# No reported cases of the unminimize-all bug

After extensive investigation across GitHub issues, Reddit discussions, Stack Overflow, and macOS forums, **the specific bug you described—where bringing a minimized window to focus causes all other minimized windows to unminimize—has not been reported by other Yabai users**. This is notable because the Yabai repository contains numerous detailed reports about minimize/deminimize issues, but none match this exact behavior.

This finding suggests either: (1) the behavior stems from macOS itself rather than Yabai, (2) it's application-specific and affects limited users, (3) it may be confused with documented macOS behavior, or (4) it represents an unreported edge case. The absence of reports across multiple platforms over several years (2021-2025) indicates this isn't a widespread Yabai bug.

## The opposite problem exists instead

What users *have* reported is the inverse behavior in **Issue #1037**: minimizing one window causes all windows of that application to minimize. This occurred specifically with Kitty terminal when using `yabai -m window --minimize` through skhd shortcuts. Developer koekeishiya attributed this to the macOS Accessibility API: "Yabai minimises a window by calling the appropriate action on the window using macOS accessibility API." The problem disappeared when minimizing within Kitty itself rather than through Yabai commands, suggesting the API doesn't always distinguish between single-window and application-level operations.

Several other minimize-related issues were documented. **Issue #2153** reveals that manually minimized windows (using the yellow minimize button) cannot be deminimized with `yabai -m window --deminimize` because Yabai reports the window has both `"has-focus":true` and `"is-minimized":true` simultaneously, causing the command to fail with "could not locate the window to act on!" **Issue #1985** similarly shows focus tracking remains incorrectly active after minimization. **Issue #1418** documented how minimized windows created invisible "holes" in BSP layouts, which was fixed in PR #1417. None of these match the all-windows-unminimize behavior.

## Root cause points to macOS API limitations

The evidence strongly suggests **macOS Accessibility API limitations** as the underlying cause of minimize/deminimize issues rather than Yabai bugs. Yabai has no native control over minimization—it simply calls macOS API actions on windows. The API's design creates several problems: application-specific handling varies significantly (Chrome behaves differently than Terminal or Safari), focus state tracking desynchronizes between Yabai and macOS, and some operations work at application level rather than per-window level.

One particularly relevant macOS behavior could explain your observation: **pressing Command+Tab to switch to an app with all windows minimized, then holding Option before releasing Command, intentionally unminimizes all windows of that app**. This is documented native macOS behavior found across multiple Apple support discussions. If you're using Command+Tab or similar focus-switching mechanisms rather than direct Yabai commands, this could create the appearance of a bug.

Application architecture also matters. Single-instance or grouped-window applications may handle minimization at the application level internally, meaning any operation targeting one window triggers restoration of all windows. The developer noted that tabs aren't supported "due to lack of macOS APIs," highlighting how API constraints limit window-level granularity.

## Workarounds focus on careful window targeting

Since no direct fix exists for the specific behavior you described, the documented workarounds address related state issues. **The most reliable approach from Issue #2153** involves focusing another window before attempting to deminimize:

```bash
# Focus another window first to clear state issues
yabai -m window --focus east
# Then deminimize specific target by ID
yabai -m window $TARGET_ID --deminimize
```

**Use explicit window IDs** rather than relative selectors to ensure precise targeting. Query minimized windows first, select your specific target, then operate on that ID:

```bash
# Get all minimized windows
yabai -m query --windows | jq '.[] | select(.\"is-minimized\"==true)'

# Deminimize specific window only
WIN_ID=$(yabai -m query --windows | jq '.[] | select(.title=="YourWindow").id')
yabai -m window $WIN_ID --deminimize
```

For workflows requiring consistent behavior, **consider using "hide" (Command-H) instead of "minimize"**. Hidden applications restore via Command-Tab keyboard shortcuts, avoiding the mouse interaction and per-window complexity that plague minimize operations. Many experienced Yabai users prefer this approach because hide operates at the application level through better-supported macOS APIs.

If deminimized windows appear in the wrong space, this signal-based solution forces them to the current space:

```bash
yabai -m signal --add event=window_deminimized \
  action="yabai -m window $YABAI_WINDOW_ID --space $(yabai -m query --spaces --space | jq .index)"
```

Note this requires SIP partially disabled for Yabai's scripting addition.

## Configuration options remain limited

Yabai provides minimal configuration specifically for minimize behavior. The core commands are:

- `yabai -m window --minimize` — Minimize target window
- `yabai -m window --deminimize` — Restore minimized window  
- `yabai -m window --focus <ID>` — Focus window (may trigger restoration)

These commands were introduced in Yabai version 2.3.0. Window queries can identify minimized state:

```bash
yabai -m query --windows --window | jq '.["is-minimized"]'
```

However, **no configuration settings control how minimize/deminimize operations behave**. Settings like `focus_follows_mouse`, `mouse_follows_focus`, and `window_animation_duration` affect general focus and animation behavior but don't specifically govern minimize restoration logic. The Yabai wiki notably doesn't even list minimize/deminimize commands on the main Commands page, reflecting their limited integration and reliance on macOS APIs.

For debugging, enable detailed logging to observe what's happening:

```bash
# In your .yabairc
yabai -m config debug_output on

# Then monitor logs
tail -f /tmp/yabai_$USER.err.log
```

Query window states before and after operations to track which windows change state and verify whether the issue affects all applications or only specific ones.

## Investigation and next steps

Since this behavior hasn't been reported, **documenting your specific case would benefit the community**. If you consistently experience this, consider opening a GitHub issue with detailed reproduction steps including: your exact Yabai version, which applications exhibit the behavior, whether it occurs with native macOS apps versus third-party apps, the specific commands or actions that trigger it, and whether it happens with manual dock clicks or programmatic focus changes.

Test systematically: Does the issue occur with all applications or only certain ones? Does it happen when using `yabai -m window --focus` versus `yabai -m window --deminimize` versus clicking the dock? Does it affect Terminal and Safari (which typically work well) or primarily Chrome and other apps (which have known issues)? These details would help distinguish between a true Yabai bug, application-specific behavior, or macOS API characteristics.

The complete absence of similar reports across multiple platforms suggests this may be an interaction between your specific configuration, the applications you use, and macOS's native restoration logic rather than a core Yabai defect. Testing with a minimal `.yabairc` configuration could help isolate whether custom rules or signals contribute to the behavior.