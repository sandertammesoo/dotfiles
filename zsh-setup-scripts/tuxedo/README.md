# tuxedo

Shell integration for [tuxedo](https://github.com/webstonehq/tuxedo) — a fast,
keyboard-driven terminal UI for the [todo.txt](https://github.com/todotxt/todo.txt)
format. It's a single static binary, fully local and offline (no accounts, API keys,
or services), so "setup" is really just deciding **which file it edits** and making
that reliable from any directory.

## Files in this module

| File            | Purpose                                                                 |
| --------------- | ----------------------------------------------------------------------- |
| `env.zsh`       | Pins a single global todo file via `$TODO_DIR` and creates the data dir |
| `functions.zsh` | `tuxedo()` wrapper that prefers a project-local `./todo.txt` when present |
| `README.md`     | This document                                                           |

## How tuxedo finds its todo file (the important bit)

Both the TUI and the CLI resolve the todo file in this strict priority order — the
first match wins:

1. **explicit `FILE` argument** — TUI only (`tuxedo ./some.txt`)
2. **`$TODO_FILE`**
3. **`$TODO_DIR/todo.txt`**
4. **`./todo.txt`** in the current directory — *only reached if neither env var is set*
5. **first-run prompt** — offers to create a new file or open a sample

### The gotcha

Because `$TODO_DIR` / `$TODO_FILE` sit **above** the current-directory check, once you
export one of them tuxedo **ignores any `./todo.txt` in your cwd**. Without an env var,
you'd instead get a *different* todo.txt depending on where you stand — tasks scattered
across directories. So this module sets a single global list... and `functions.zsh`
adds back per-project lists deliberately (see below).

## What this module configures

`env.zsh` sets:

```sh
export TODO_DIR="$XDG_DATA_HOME/tuxedo"   # -> ~/.local/share/tuxedo/todo.txt here
```

This is XDG-compliant (matching the rest of the dotfiles) and keeps `todo.txt` and its
sibling `done.txt` together. The directory is created on shell startup so the first
launch doesn't drop into the create/sample prompt.

> **Want the list synced across machines?** Point `TODO_DIR` at an iCloud/Dropbox
> folder instead, e.g.
> `export_n_log TODO_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/todo"`.

## Per-project todo lists (`functions.zsh`)

The `tuxedo()` wrapper restores (and extends) per-directory behaviour the global
`$TODO_DIR` would otherwise suppress. It searches for a `todo.txt` starting in the
current directory and **walking up the parent directories as far as `$HOME`** — the
nearest one wins:

- A `todo.txt` in `$PWD` or any ancestor up to `$HOME` → that file is used
  (via `TODO_FILE=...`, which works for both the TUI and CLI subcommands).
- Nothing found by the time it reaches `$HOME` → the global `$TODO_DIR/todo.txt`.

The walk never climbs above `$HOME`; for a `$PWD` outside `$HOME`, only `$PWD` itself is
checked (so it won't scan `/tmp → /`).

```sh
# ~/projects/foo/todo.txt exists
cd ~/projects/foo/src/lib
tuxedo add "fix the parser +foo"   # walks up, finds ~/projects/foo/todo.txt

cd ~/scratch                       # no todo.txt here or above (until ~)
tuxedo add "buy milk"              # falls back to ~/.local/share/tuxedo/todo.txt (global)
```

To **force the global list** from inside a tree that has a `todo.txt`, bypass the
wrapper:

```sh
command tuxedo add "global task"
```

To **start** a project-local list, create the file at the root of the tree you want it
to cover:

```sh
touch ./todo.txt
```

## done.txt (archiving)

Pressing `A` in the TUI appends completed tasks to a sibling `done.txt` (atomically) and
removes them from the working file. It lives next to `todo.txt` — so `$TODO_DIR/done.txt`
globally, or `./done.txt` for a project list. Override with `$DONE_FILE` only if you want
the archive somewhere else; missing parent dirs are created on first use.

## Other config (optional, not managed here)

- **`~/.config/tuxedo/config.toml`** — mostly written automatically by the app as you
  cycle theme (`T`), density (`D`), sort (`S`), layout (`[ ] L`), done-visibility (`H`),
  and save searches (`fs`). **Don't hand-edit those**; let the TUI own them. Unknown keys
  are ignored, so it's forward-compatible across versions.
  - Exception — **`hide_keys`** is the one setting you *do* edit by hand (there's no TUI
    toggle). It's a comma-separated, case-insensitive list of `key:value` extension keys
    to drop from the task rows, e.g. `hide_keys = uid, sync`. Hiding is purely visual: the
    tags stay on disk, still serialize, still show in the detail pane's **RAW** section,
    and searches still match them. It's global — one `config.toml` applies to every list.
  - Custom `key:value` metadata otherwise needs **no config** — add tags like `est:3h` or
    `uid:abc` to any task and they display by default (`due:YYYY-MM-DD` is special: used for
    sort and due-bucket grouping).
- **Custom keybindings / themes** — drop `~/.config/tuxedo/keybinds.toml` or theme
  `.toml` files in `~/.config/tuxedo/themes/`. Not needed to get started; built-in
  vim-style bindings and five themes work out of the box.
- **`TUXEDO_NO_UPDATE_CHECK=1`** — set in `env.zsh` (commented out) to skip the network
  version check on shell startup.

## Verify

```sh
exec zsh                       # reload shell so env.zsh + functions.zsh apply
tuxedo --version
echo "$TODO_DIR"               # -> ~/.local/share/tuxedo
tuxedo add "set up tuxedo +tooling"
tuxedo ls                      # task should appear
tuxedo                         # launch the TUI; 'q' to quit
```
