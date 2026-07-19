# Dotfiles

Personal macOS environment configuration: shell, terminal tooling, window
management, and the integrations between them.

## Language

### Tool provisioning

**Runtime**:
A language toolchain (Node, Python, Go) whose version is switchable
per-directory. Owned by mise; never installed as a first-class Homebrew
formula.
_Avoid_: interpreter, SDK

**System tool**:
A CLI installed at a single machine-wide version via Homebrew (ripgrep,
lazygit, mise itself). Not version-switched per project.
_Avoid_: package, dependency

**Auto-venv**:
A project-local Python virtual environment (`.venv`) declared in the
project's `mise.toml`, activated on directory entry. Replaces named
pyenv-virtualenv environments.
_Avoid_: virtualenv, named environment

### Diff tooling

**Review UI**:
An interactive viewer that takes over the whole terminal to present a
changeset for review (hunk). Invoked deliberately; owns the screen until
dismissed.
_Avoid_: pager, diff viewer

**Stream colorizer**:
A non-interactive filter that decorates diff or text output with ANSI colors
so a host tool can display it (delta). Never takes over the terminal.
_Avoid_: pager, syntax highlighter

**Embedded pane**:
A region inside a host TUI (e.g. lazygit's main panel) that shows captured
command output. Can only render what a stream colorizer emits; cannot host a
review UI.
_Avoid_: preview window, split
