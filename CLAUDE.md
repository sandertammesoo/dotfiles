# CLAUDE.md

Personal macOS dotfiles (Intel + Apple Silicon). XDG Base Directory compliant throughout. Modular zsh config loaded by file suffix (`env.zsh`, `aliases.zsh`, `functions.zsh`, `completion.zsh`) via `get_zsh_files()`. 285 ShellSpec tests.

## Commands

```bash
./run-dotbot   # symlinks + XDG dirs only (first step on new machine)
./install-all  # full setup; see source for --skip-* and logging flags
shellspec      # run all 285 tests
```

## Installation System

`install-all` runs DotBot → whitelisted installers → services. **New `install.sh` scripts must be added to `allowed_installer_paths` in `install-all` before they'll execute** — they are silently skipped otherwise.

## Logging (`helpers_logging.zsh`)

```bash
LOG_LEVEL="INFO"       # TRACE VERBOSE DEBUG INFO WARN ERROR FATAL
LOG_ENABLED="false"    # debug mode toggle
LOG_FORMAT="standard"  # minimal | standard | detailed
LOG_COLOR="auto"       # auto | always | never
```

Functions: `log_trace/debug/verbose/info/warn/error/fatal/success/fail/skip/user`, `enable_debug`, `disable_debug`, `set_log_level`, `print_log_level`, `try_source FILE [LOGLEVEL]`, `export_n_log VAR VALUE` (redacts secrets), `add_to VAR PATH` (no duplicates), `output_stream`.

## Yabai (`xdg_config/yabai/yabairc`)

`application_activated` and `window_created` signals are **DISABLED** — their `yabai -m query --windows` calls deminimize minimized windows system-wide. Do not re-enable without reading `.claude/YABAI_MINIMIZE_BUG/`.

## Code Style

1. All output via `log_*` functions — never raw `echo` in scripts
2. Boolean flags: `true`/`false` strings not `0`/`1`; check with `[[ "${FLAG:-false}" == "true" ]]`
3. Sudo keep-alive: `(for i in {1..60}; ...) &` with `kill -0 $$` parent check + `trap cleanup EXIT`
4. Variable existence vs empty: `[[ -n "${VAR+x}" ]]`

## Skills

- `/new-zsh-module` — add a new tool/module to `zsh-setup-scripts/`
- `/shellspec-add-test` — write new ShellSpec tests
- `/yabai-debug` — diagnose yabai/window management issues
- `/shell-debug` — diagnose shell startup and config loading issues

## Resources

- `.claude/YABAI_MINIMIZE_BUG/` — minimize bug full investigation
- `.claude/YABAI_SKHD/` — SKHD config reference and fixes
- `.claude/README.md` — logging framework refactoring docs
- `NEW_MACHINE.md` — new machine setup checklist
