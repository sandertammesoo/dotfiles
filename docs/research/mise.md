# Research: mise (mise-en-place)

**Date:** 2026-07-19
**Latest release at time of research:** v2026.7.7 (2026-07-15) — mise uses CalVer (`vYYYY.M.PATCH`)
**Primary sources:** official docs at [mise.jdx.dev](https://mise.jdx.dev) and the [jdx/mise](https://github.com/jdx/mise) GitHub repo.

> **Note on location:** this repo had no research-notes convention (`docs/` only contained
> `agents/` and `adr/`), so `docs/research/` was created for this document.

## Recommendation summary (for this dotfiles repo)

mise is a strong fit for this repo and would consolidate three concerns — runtime version
management (asdf/nvm/pyenv territory), per-directory env vars (direnv territory), and project
task running — into a single Rust binary installed via Homebrew. It is XDG-compliant almost
everywhere: config in `$XDG_CONFIG_HOME/mise`, data in `$XDG_DATA_HOME/mise`, state in
`$XDG_STATE_HOME/mise`. The one macOS wrinkle: **cache defaults to `~/Library/Caches/mise` on
macOS**, so a strictly XDG setup should export `MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"`.
Idiomatic setup for this repo: `brew install mise`, add `eval "$(mise activate zsh)"` to an
`env.zsh` module (interactive shells), point CI/IDE contexts at shims, keep global tool
versions in a dotbot-linked `xdg_config/mise/config.toml`, and prefer aqua/core backends over
asdf plugins for supply-chain hygiene. Main caveats: config files can execute code (mitigated
by the trust prompt / paranoid mode), `.nvmrc`-style files are opt-in per tool, and mise should
not be combined with direnv or other version managers managing the same tools.

---

## 1. What mise does

mise (pronounced "meez", from *mise-en-place*) describes itself as "a development environment
setup tool" providing "a consistent way to setup and interact with your projects no matter what
language they're written in." It was created by Jeff Dickey and is written in Rust (it began as
`rtx`, an asdf-compatible rewrite). It has three functions
([about](https://mise.jdx.dev/about.html)):

1. **Dev tools** — installs and manages versions of runtimes and CLIs (Node, Python, Terraform,
   hundreds more), with versions pinned per project. Successor to asdf-style workflows and a
   replacement for per-language managers.
2. **Environments** — sets project-specific environment variables (e.g. `AWS_ACCESS_KEY_ID`)
   when you `cd` into a directory, including automatic Python virtualenv activation — the
   direnv use case ([environments](https://mise.jdx.dev/environments/)).
3. **Tasks** — a task runner to "share common tasks within a project among developers", with
   dependency graphs, parallelism, and file-watch mode ([tasks](https://mise.jdx.dev/tasks/)).

## 2. How it works

### Config files

([configuration](https://mise.jdx.dev/configuration.html))

- Project config lives in `mise.toml` (or `.mise.toml` — any `mise*` filename can be a
  dotfile). Precedence, highest first: `mise.local.toml` (git-ignored local overrides) →
  `mise.toml` → `mise/config.toml` → `.config/mise.toml` → `.config/mise/conf.d/*.toml`.
  Environment-specific variants (`mise.production.toml`) and platform variants
  (`mise.windows.toml`) are supported.
- mise **walks up the directory tree** merging configs; closer directories override broader
  ones. Tools and env vars merge additively with overrides; tasks are replaced wholesale.
- **asdf compatibility:** mise reads `.tool-versions` files (fuzzy versions, `latest`,
  VCS refs), though `mise.toml` is recommended.
- Global config: `~/.config/mise/config.toml` (i.e. `$MISE_CONFIG_DIR/config.toml`) — the docs
  explicitly describe it as intended for dotfiles repos. System-wide: `/etc/mise/config.toml`.

### Activation: PATH vs shims vs neither

([shims](https://mise.jdx.dev/dev-tools/shims.html),
[activate](https://mise.jdx.dev/cli/activate.html))

- **PATH activation** (`eval "$(mise activate zsh)"` in `.zshrc`): a `hook-env` runs before
  each prompt and edits `PATH` and env vars directly. Full feature set (env vars everywhere;
  `cd`/enter/leave hooks). Cost is a few ms per prompt, zero per tool invocation.
- **Shims**: symlink-like executables in `~/.local/share/mise/shims` that resolve the right
  tool version per call. Better for **non-interactive contexts** (IDEs, CI, scripts) where no
  prompt is ever drawn; limitations: mise-defined env vars are only visible to mise-run tools,
  most hooks don't fire, and `which node` shows the shim (use `mise which`).
- **Neither**: `mise exec`, `mise run`, and `mise en` load the full environment for a single
  command/session with no shell integration at all.

### Backends and the registry

([backends](https://mise.jdx.dev/dev-tools/backends/),
[registry](https://mise.jdx.dev/registry.html),
[core tools](https://mise.jdx.dev/core-tools.html))

- **Core backend**: 12 tools implemented natively in Rust, no plugin needed — Bun, Deno,
  Elixir, Erlang, Go, Java, Node.js, Python, Ruby, Rust, Swift, Zig.
- Other backends: `aqua`, `ubi`, `github`/`gitlab`/`forgejo`, `asdf` (legacy plugins), `vfox`,
  `cargo`, `npm`, `pipx`, `gem`, `go`, `conda`, `dotnet`, `http`, `s3`, `spm`, `pkgx`.
- The **registry** maps short names (`mise use aws-cli`) to full backend specs
  (`aqua:aws/aws-cli`). Backend tiers for new registry entries: **aqua/github/gitlab preferred**
  ("aqua offers the most features and security while not requiring plugins"); conda second;
  language-package backends (pipx/npm/gem/go/cargo/dotnet) rarely accepted because "they
  silently bind tools to whichever node/python/ruby happened to be on PATH at install time."

### Trust model

([`mise trust`](https://mise.jdx.dev/cli/trust.html),
[paranoid mode](https://mise.jdx.dev/paranoid.html))

- Because `mise.toml` can execute code (templates, `env._.source`, tool options), mise requires
  config files to be **trusted** before parsing them: it prompts interactively, errors when it
  can't prompt, and assumes trust in CI unless paranoid mode is on. "Safe" configs (plain
  version strings, no templates) load without trust.
- Trust is shared across git worktrees; state is stored in the state dir.
- **Paranoid mode** (`MISE_PARANOID=1`): every config needs explicit trust, trusted files are
  content-hashed (re-trust on change), plugin shorthands are disabled (full URLs required),
  HTTPS is enforced, and provenance is re-verified on every install.

## 3. Comparison with alternatives

### vs asdf

([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html))

- **Performance**: asdf's bash shims add ~120 ms to *every* runtime call; mise's `hook-env`
  adds ~5 ms *per prompt* and tool calls run at native speed because `PATH` is modified
  directly. Rust vs bash compounds the difference.
- **Security**: asdf plugins "involve shell code which can essentially do anything on your
  machine," written by authors typically unaffiliated with the tool vendor. mise prefers
  plugin-free backends (aqua/github) with "native Cosign/SLSA/Minisign/GitHub attestation
  verification."
- **UX**: fuzzy versions (`mise install node@20`), one-command `mise use node@20`.
- **Compatibility**: reads `.tool-versions` and can run asdf plugins via the asdf backend,
  though "100% compatibility is not a design goal."

### vs nvm / pyenv / rbenv

One mise replaces N per-language managers: Node, Python, and Ruby are all core (Rust-native)
plugins ([core tools](https://mise.jdx.dev/core-tools.html)), pinned together in one
`mise.toml` per project instead of `.nvmrc` + `.python-version` + `.ruby-version`. mise *can*
read those idiomatic files, but support is **disabled by default** and opted in per tool:
`mise settings add idiomatic_version_file_enable_tools node`
([FAQ](https://mise.jdx.dev/faq.html)). Unlike nvm (a shell function that mutates PATH on
`nvm use`), switching is automatic per directory via activation.

### vs direnv

([direnv](https://mise.jdx.dev/direnv.html))

- "mise is capable of replacing direnv for most use-cases": `[env]` tables, `env._.file`
  (dotenv/JSON/YAML/TOML), `env._.path` for PATH entries, `env._.source` for sourcing scripts,
  Tera templates, and automatic virtualenv activation
  ([environments](https://mise.jdx.dev/environments/)).
- Official position: "you should not use direnv with mise" — both mutate env per directory and
  PATH-ordering conflicts arise when both manage the same tool. "Issues arising from
  incompatibilities are not considered bugs." The old `use mise` `.envrc` helper is deprecated.
- direnv remains more general (arbitrary shell in `.envrc`); mise is declarative TOML plus
  escape hatches.

### vs make / just (task runner)

([tasks](https://mise.jdx.dev/tasks/))

- Tasks are defined as TOML in `mise.toml` (`[tasks.build]`) or as **file tasks** — real shell
  scripts in `mise-tasks/` with `#MISE description="…"` comment metadata, keeping shellcheck /
  syntax highlighting usable (an advantage over make recipes and TOML-embedded strings).
- Dependencies run **in parallel by default**; last-modified checking skips unchanged work
  (make-style, without Makefile syntax); `mise watch` rebuilds on file change.
- The decisive difference from make/just: tasks run *inside* the mise environment — correct
  tool versions and `[env]` vars are injected automatically, plus context vars like
  `MISE_PROJECT_ROOT` and `MISE_CONFIG_ROOT`. The docs make no direct feature-matrix claim
  against just; the differentiator is integration, not raw task syntax.

## 4. Fit for this dotfiles repo (macOS, Intel + Apple Silicon)

- **Install**: `brew install mise` is an officially documented method
  ([getting started](https://mise.jdx.dev/getting-started.html)); a single formula covers both
  architectures. (The alternative `curl https://mise.run | sh` installs to `~/.local/bin`.)
- **zsh activation**: `eval "$(mise activate zsh)"` in `.zshrc`
  ([getting started](https://mise.jdx.dev/getting-started.html),
  [activate](https://mise.jdx.dev/cli/activate.html)) — in this repo, an
  `env.zsh` module picked up by `get_zsh_files()`. Verify with `mise doctor`.
- **XDG compliance** ([directories](https://mise.jdx.dev/directories.html)):

  | Purpose | Default | Honors XDG var | Override |
  |---|---|---|---|
  | Config | `~/.config/mise` | `XDG_CONFIG_HOME` | `MISE_CONFIG_DIR` |
  | Data (plugins, installs, shims) | `~/.local/share/mise` | `XDG_DATA_HOME` | `MISE_DATA_DIR` |
  | State (trust records) | `~/.local/state/mise` | `XDG_STATE_HOME` | `MISE_STATE_DIR` |
  | Cache | Linux `~/.cache/mise`; **macOS `~/Library/Caches/mise`** | `XDG_CACHE_HOME` (Linux) | `MISE_CACHE_DIR` |

  For strict XDG on macOS, export `MISE_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mise"`.
  Global config (`xdg_config/mise/config.toml`) can be dotbot-linked like other modules — the
  docs explicitly call the config dir the place "intended for dotfiles repos."
- **Homebrew interaction**: activation prepends mise's tool paths, so mise-managed versions win
  over brew-installed ones inside mise-managed directories; Homebrew stays for casks, libraries
  and tools you don't version-pin. mise's own upgrade rides `brew upgrade`. Keep only one
  manager per tool (same rule the direnv page applies to PATH conflicts).

## 5. Caveats

1. **Configs execute code**: any cloned repo's `mise.toml` can run shell via templates or
   `env._.source`. The trust prompt is the guard — never blanket-`mise trust --all` untrusted
   trees; consider `MISE_PARANOID=1` ([paranoid](https://mise.jdx.dev/paranoid.html),
   [trust](https://mise.jdx.dev/cli/trust.html)).
2. **Supply chain**: asdf-backend community plugins are arbitrary shell from third parties.
   Prefer core/aqua/ubi/github backends, which are plugin-free and support
   Cosign/SLSA/Minisign/attestation verification
   ([comparison-to-asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html),
   [registry](https://mise.jdx.dev/registry.html)).
3. **Idiomatic version files off by default**: `.nvmrc`/`.python-version` need per-tool opt-in
   (`idiomatic_version_file_enable_tools`) — surprising when migrating from nvm/pyenv
   ([FAQ](https://mise.jdx.dev/faq.html)).
4. **Don't stack managers**: no direnv alongside mise for the same tools; likewise retire
   nvm/pyenv shims from PATH to avoid ordering fights
   ([direnv](https://mise.jdx.dev/direnv.html)).
5. **Shims are second-class**: env vars and hooks don't fully work through shims; use PATH
   activation interactively and shims only for IDEs/CI
   ([shims](https://mise.jdx.dev/dev-tools/shims.html)).
6. **macOS cache dir breaks strict XDG** unless `MISE_CACHE_DIR` is set (see table above).
7. **Fast-moving CalVer releases** (multiple per month; v2026.7.7 as of 2026-07-15) — pin via
   Homebrew if churn becomes an issue
   ([releases](https://github.com/jdx/mise/releases)).

## Sources

- About: https://mise.jdx.dev/about.html
- Getting started (install, zsh activation): https://mise.jdx.dev/getting-started.html
- Configuration (file hierarchy, `.tool-versions`, env vars): https://mise.jdx.dev/configuration.html
- Directories (XDG defaults): https://mise.jdx.dev/directories.html
- Shims vs PATH: https://mise.jdx.dev/dev-tools/shims.html
- `mise activate`: https://mise.jdx.dev/cli/activate.html
- Backends: https://mise.jdx.dev/dev-tools/backends/
- Registry and backend tiers: https://mise.jdx.dev/registry.html
- Core tools: https://mise.jdx.dev/core-tools.html
- Comparison to asdf: https://mise.jdx.dev/dev-tools/comparison-to-asdf.html
- Environments: https://mise.jdx.dev/environments/
- Tasks: https://mise.jdx.dev/tasks/
- direnv: https://mise.jdx.dev/direnv.html
- Trust: https://mise.jdx.dev/cli/trust.html
- Paranoid mode: https://mise.jdx.dev/paranoid.html
- FAQ (idiomatic version files): https://mise.jdx.dev/faq.html
- Latest release (v2026.7.7, 2026-07-15): https://github.com/jdx/mise/releases
