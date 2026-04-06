# Yabai Debug

Diagnose yabai window manager issues using a structured checklist. Covers known failure modes on macOS 26 Tahoe.

## When to use

Yabai not starting, windows not tiling, focus broken, minimize/deminimize bugs, signal issues, scripting addition failures.

## Quick diagnostic commands

```bash
# Service status
yabai --list-services
yabai --restart-service

# Query current state
yabai -m query --windows
yabai -m query --spaces
yabai -m query --displays

# Live debug log
tail -f /tmp/yabai_minimize_debug.log

# Scripting addition
sudo yabai --load-sa

# Sudoers
cat /private/etc/sudoers.d/yabai
```

## Diagnostic checklist

### 1. Is the service running?

```bash
yabai --list-services
```

If not: `yabai --start-service`. If it fails to start, check SIP and scripting addition.

### 2. Is the scripting addition loaded?

```bash
sudo yabai --load-sa
```

**Known macOS 26 Tahoe failure modes** (see `.claude/YABAI_MINIMIZE_BUG/` for full context):

| Symptom | Cause | Fix |
|---------|-------|-----|
| `PAC ABI mismatch` error | yabai binary doesn't match Dock.app ABI | Upgrade yabai: `brew upgrade yabai` then re-run bootstrap |
| Silent exit code 1, no output | Sudoers hash mismatch (yabai was upgraded) | Recalculate SHA256 and update `/private/etc/sudoers.d/yabai` via `bootstrap.sh` |
| `could not locate Dock.app pid` | SIP partially enabled or Dock crashed | Check SIP: `csrutil status`; restart Dock: `killall Dock` |

To fully refresh sudoers after a yabai upgrade:
```bash
zsh-setup-scripts/yabai/bootstrap.sh
```

### 3. Check the sudoers entry

```bash
cat /private/etc/sudoers.d/yabai
```

The SHA256 hash in the file must match the currently installed yabai binary. If yabai was upgraded, the hash is stale — run `bootstrap.sh`.

### 4. Check which signals are active

In `xdg_config/yabai/yabairc`, these signals are **deliberately disabled** due to a minimize bug:
- `application_activated` — causes window queries that deminimize minimized windows system-wide
- `window_created` — same root cause

**Do not re-enable these without reading `.claude/YABAI_MINIMIZE_BUG/FINAL_ROOT_CAUSE_SOLUTION.md`.**

Active signals: `window_focused`, `window_minimized`, `window_deminimized`, `application_front_switched`, `title_changed` (Slack help window float).

### 5. Window focus / borders not working

Borders uses `ax_focus` for floating window tracking. If focus indicators are wrong:
- Check `~/.config/borders/bordersrc` — `ax_focus=on` must be set
- Verify the `borders_focus_refresh` signal in `yabairc` (sends `window_focused` on `application_front_switched`)

### 6. Opacity not applying

Opacity is managed via signals in `yabairc`. Two modes: `always` (all windows) and `focus` (only focused window). Check:
- `yabai_opacity_mode` variable at top of yabairc
- App-name matching (Brave Browser registers as "Brave Browser", not "Brave")

## Key files

| File | Purpose |
|------|---------|
| `xdg_config/yabai/yabairc` | Main config: rules, signals, settings |
| `zsh-setup-scripts/yabai/bootstrap.sh` | Install, sudoers, load-sa |
| `/private/etc/sudoers.d/yabai` | Passwordless load-sa entry |
| `/tmp/yabai_minimize_debug.log` | Runtime debug log |
| `.claude/YABAI_MINIMIZE_BUG/` | Full minimize bug investigation (9 files) |
| `.claude/YABAI_SKHD/` | SKHD config reference and fixes |

## SKHD issues

If hotkeys aren't working:
```bash
skhd --restart-service
skhd -o  # show observed events
```

Check `xdg_config/skhd/skhdrc` for the keybinding definitions.
