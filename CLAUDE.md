# CLAUDE.md

Personal macOS dotfiles (Intel + Apple Silicon). XDG Base Directory compliant throughout. Modular zsh config loaded by file suffix (`env.zsh`, `aliases.zsh`, `functions.zsh`, `completion.zsh`) via `get_zsh_files()`. 303 ShellSpec tests.

## Commands

```bash
./run-dotbot   # symlinks + XDG dirs only (first step on new machine)
./install-all  # full setup; see source for --skip-* and logging flags
shellspec      # run all 303 tests (also: mise run test / mise run link)
```

Language runtimes (node, python, go) are owned by **mise**, never Homebrew — see `docs/adr/0001-mise-for-runtime-management.md` and CONTEXT.md "Tool provisioning".

## Secret Scanning

This repo is **public**. A gitleaks pre-commit hook is installed **machine-wide** via `core.hooksPath` in `xdg_config/git/config`, so it gates every repo on the box, not just this one. See `docs/adr/0002-secret-scanning.md`.

```bash
secrets-audit             # gitleaks over the full history of the current repo
secrets-audit --verify    # + trufflehog, which live-checks whether a secret still works
secrets-audit --hooks     # list repos whose local core.hooksPath bypasses the gate
GITLEAKS_SKIP=1 git commit ...   # bypass once
```

Three rules when a scan fires:

1. **Never** put a fingerprint in `.gitleaksignore` for a credential that still authenticates. Rotate first, suppress after.
2. Recurring false positives belong in `.gitleaks.toml` as an allowlist (survives line-number changes), not in `.gitleaksignore` (pinned to `commit:path:rule:line`).
3. `--config`/`GITLEAKS_CONFIG` **override** a repo-local `.gitleaks.toml` — the hook passes the global baseline only when the repo has none. Do not "simplify" that away.

Secrets belong in 1Password and are read at runtime; `xdg_config/harlequin/scripts/hq-sql` is the reference pattern.

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
- `docs/adr/0002-secret-scanning.md` — why gitleaks gates and trufflehog audits
- `NEW_MACHINE.md` — new machine setup checklist

## Agent skills

### Issue tracker

Issues are tracked as GitHub Issues on `sandertammesoo/dotfiles` via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
