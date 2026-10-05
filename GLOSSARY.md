# Dotfiles

Personal macOS environment configuration: shell, terminal tooling, window
management, and the integrations between them.

## Language

### Tool provisioning

**Runtime**:
A language toolchain (Node, Python, Go, Rust) whose version is switchable
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

### Secret scanning

**Gate**:
A control that stops a secret before it enters the repository (the gitleaks
pre-commit hook, GitHub push protection). Runs on every commit or push and
blocks.
_Avoid_: scanner, checker, linter

**Auditor**:
A scan of history that reports what is already committed (trufflehog, the CI
job). Runs on demand or on a schedule and never blocks a commit.
_Avoid_: scanner

**Finding**:
One match a tool reports. A finding is a candidate, not a proven secret.
_Avoid_: leak, alert, hit

**Verified finding**:
A finding that still authenticates against its provider. Rotate it before
anything else. Only trufflehog verifies.
_Avoid_: live key, valid secret, true positive

**Allowlist**:
A rule in `.gitleaks.toml` that suppresses a class of findings by pattern or
path. Survives a change of line numbers.
_Avoid_: exception, exclusion

**Fingerprint suppression**:
An entry in `.gitleaksignore` that suppresses one exact finding by
`commit:path:rule:line`. Correct for a dead historical leak, wrong for a
recurring pattern.
_Avoid_: baseline, ignore rule

### Database access

**Connection field**:
One of the five values a profile needs to reach a database: host, port,
database, user, password. Carried as one unit, never singly.
_Avoid_: credential, connection detail, connection string

**Credential cache**:
The `0600` file that holds the five connection fields read from a 1Password
item. Persistent, and shared by every run for one environment.
_Avoid_: session, token store, keychain

**Ephemeral profile**:
The harlequin TOML profile that `hq-sql` writes at each run and deletes at
the end of the run. Private to one run, and the only file the runner is given.
_Avoid_: temp config, generated config

**Idle window**:
The period after the last use of a credential cache during which the cache
stays valid. Measured from the file mtime, and touched on every hit.
_Avoid_: TTL, session length

**Fetch ceiling**:
The maximum age of a credential cache measured from the 1Password read.
Outranks the idle window, so a busy session still expires.
_Avoid_: max TTL, hard expiry, absolute TTL

**Unattended auth**:
1Password access through a service account token, which prompts for no
biometric. The alternative is the desktop app integration.
_Avoid_: headless mode, CI mode, non-interactive auth
