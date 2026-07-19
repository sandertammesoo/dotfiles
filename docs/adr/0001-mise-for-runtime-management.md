# mise owns all runtimes; Homebrew provides system tools only

We replaced fnm (Node) and pyenv + pyenv-virtualenv (Python) with mise
(https://mise.jdx.dev) as the single owner of language runtimes — Node, Python,
and Go — because one Rust-based tool covers version management, per-directory
env vars, and tasks, with PATH activation instead of per-call shim overhead.
Runtimes are never installed as first-class Homebrew formulae (Homebrew's
`node` remains on disk only as a dependency of other formulae; mise's
activation hook puts its runtimes ahead of `/opt/homebrew/bin` from the first
prompt onward, though during `.zshrc` sourcing itself Homebrew's node still
resolves first); named pyenv-virtualenv environments were dropped in favor of
project-local auto-venvs declared in each project's `mise.toml`.

## Consequences

- Global runtime versions are pinned in `xdg_config/mise/config.toml`;
  idiomatic version files (`.nvmrc`, `.node-version`, `.python-version`) are
  honored for node and python to keep parity with the old fnm `--use-on-cd`
  behavior in projects that predate mise.
- Interactive shells use `mise activate` (zsh-setup-scripts/mise/env.zsh);
  non-interactive shells and `command -v` guards in env modules resolve tools
  through the shims dir added to PATH in `.zshenv`. The shims entry must stay
  in `.zshenv` — moving it later than the env-module block breaks the guards.
- `MISE_CACHE_DIR` is forced to `$XDG_CACHE_HOME/mise` in `.zshenv` because
  mise's macOS default is `~/Library/Caches/mise`, violating this repo's
  strict XDG compliance.
- Do not install direnv or another version manager alongside mise; the
  official docs advise against stacking them.
