# Dotfiles

Personal macOS environment configuration: shell, terminal tooling, window
management, and the integrations between them.

## Language

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
