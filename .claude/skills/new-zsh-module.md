# New Zsh Module

Guide the user through adding a new tool/module to the dotfiles zsh configuration.

## When to use

User says things like "add [tool] support", "create a new module for [tool]", "set up [tool] in dotfiles".

## Workflow

### Step 1: Determine what's needed

Ask (or infer from context) which of these the new tool requires:
- Environment variables → `env.zsh`
- Aliases → `aliases.zsh`
- Shell functions → `functions.zsh`
- Tab completion → `completion.zsh`
- Installation script → `install.sh`
- Config symlink (e.g. `~/.config/[tool]/`) → update `dotbot.conf.yaml`

### Step 2: Create the directory

```bash
mkdir -p zsh-setup-scripts/[tool]/
```

Check `zsh-setup-scripts/` for existing modules to use as reference patterns.

### Step 3: Scaffold the files

Only create files that are actually needed. Follow these patterns from the codebase:

**`env.zsh`** — use `export_n_log VAR "value"` and `add_to PATH "/path"`, guard with `[[ -z "$VAR" ]]` if needed

**`aliases.zsh`** — plain `alias` declarations

**`functions.zsh`** — functions with `# shellcheck shell=zsh` header and brief docstring comments

**`completion.zsh`** — usually just sources the tool's completion: `source <(tool completion zsh)`

**`install.sh`** — use `log_info`/`log_error` from the logging framework; check `is_installed.sh` pattern from existing modules

### Step 4: Check if dotbot.conf.yaml needs updating

If the tool needs a config directory symlinked into `~/.config/`:

```yaml
# In dotbot.conf.yaml, under the link section:
~/.config/[tool]: xdg_config/[tool]
```

Also add the directory creation under the `create` section if needed.

### Step 5: Check if install.sh needs whitelisting

If an `install.sh` was created and should run automatically via `install-all`, add it to the whitelist in `install-all`:

```zsh
local allowed_installer_paths=(
  "zsh-setup-scripts/homebrew/install.sh"
  "zsh-setup-scripts/osx/install.sh"
  "zsh-setup-scripts/[tool]/install.sh"   # ← add here
)
```

### Step 6: Test

```bash
LOG_LEVEL=DEBUG LOG_ENABLED=true zsh
```

Verify the new module loads without errors. Check with `print_log_level` and look for any sourcing failures.

### Step 7: Update CLAUDE.md

Add the tool to the directory structure comment in CLAUDE.md if it's significant.

## Key files to reference

- `zsh-setup-scripts/` — existing modules for pattern reference
- `dotbot.conf.yaml` — symlink/directory creation config
- `install-all` — whitelist array (search for `allowed_installer_paths`)
- `helpers_logging.zsh` — logging functions available in all scripts
- `xdg_config/zsh/` — core zsh config loaded before modules
