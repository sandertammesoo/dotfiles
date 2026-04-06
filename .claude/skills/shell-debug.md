# Shell Debug

Diagnose shell startup issues, configuration loading problems, and missing functions/variables.

## When to use

Shell functions not available, env vars missing, slow startup, `.zshenv` not loading, zsh config errors, unexpected tool behavior after config changes.

## Shell loading chain

```
~/.zshenv → helpers.zsh → helpers_logging.zsh + helpers_misc.zsh
         ↓
         └→ Set XDG vars → add_to PATH → source zsh/fpath.zsh

~/.zshrc → homebrew/env.zsh → zsh/config.zsh → .localrc (if exists)
        ↓
        └→ env.zsh files → other.zsh → aliases.zsh → functions.zsh
        ↓
        └→ compinit → completion.zsh files → zoxide/env.zsh
```

**Key entry points:**
- `~/.zshenv` → `xdg_config/zsh/.zshenv` (symlinked by DotBot)
- `~/.zshrc` → `xdg_config/zsh/.zshrc`
- `helpers.zsh` — central loader; must be healthy for everything downstream to work
- `ZDOTDIR="$HOME/.config/.zsh"` — where zsh looks for config files

## Enable debug logging

```bash
# Runtime toggle
enable_debug
set_log_level DEBUG

# Or launch a new shell with debug on
LOG_LEVEL=DEBUG LOG_ENABLED=true zsh

# Check current level
print_log_level
is_debug_enabled
```

## Diagnostic checklist

### 1. Is `.zshenv` symlinked correctly?

```bash
ls -la ~/.zshenv
echo $ZDOTDIR   # should be $HOME/.config/.zsh
```

If not: run `./run-dotbot` from the dotfiles repo.

### 2. Is `helpers.zsh` loading?

```bash
# Check if logging functions are available
type log_info
type enable_debug
```

If missing: `helpers.zsh` failed to source. Check for syntax errors:
```bash
zsh -n helpers.zsh
zsh -n helpers_logging.zsh
```

### 3. Is a specific module failing to load?

```bash
LOG_LEVEL=TRACE LOG_ENABLED=true zsh 2>&1 | head -100
```

Look for `try_source` failures — they log at WARN by default.

### 4. Is a function or alias missing?

Check which category file it should be in (`env.zsh`, `aliases.zsh`, `functions.zsh`) and whether `get_zsh_files()` is discovering it:

```bash
# In a running shell, check what was discovered
LOG_LEVEL=DEBUG LOG_ENABLED=true source ~/.zshenv
```

`get_zsh_files()` loads files by suffix category, with explicit exclusions for: `homebrew/env.zsh`, `zoxide/env.zsh`, `zsh/config.zsh`, `zsh/fpath.zsh`.

### 5. Reload config without opening a new shell

```bash
source ~/.zshenv   # reload env + helpers
# or use the alias if defined:
reload!
```

## Common fixes

| Symptom | Fix |
|---------|-----|
| `ZDOTDIR` not set | DotBot symlink missing — run `./run-dotbot` |
| Function defined but not found | Wrong file suffix (`functions.zsh` not `function.zsh`) |
| Env var not exported | In a `functions.zsh` instead of `env.zsh`; category loaded after prompt |
| Completion not working | Must be in `completion.zsh`; loaded after `compinit` |
| Zoxide not working | `zoxide/env.zsh` must load after `compinit`; check exclusion list |
