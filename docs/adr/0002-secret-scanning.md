# gitleaks gates every commit, trufflehog audits history

This repository is public and holds 296 commits that reach back to 2016. It
carries no application credentials, but it does carry the shell that opens
them. A leaked token here is a leaked token everywhere.

We adopted **gitleaks** as the always-on gate and **trufflehog** as the
on-demand auditor. The two tools answer different questions. gitleaks answers
"does this diff contain something that looks like a secret", fast enough to
run before every commit. trufflehog answers "is this secret still live",
which needs a network call to the provider and takes too long for a hook.

## Why gitleaks and not the alternatives

We compared four tools.

| Tool | Verdict |
|---|---|
| **gitleaks** | Chosen. No account, no API token, a Homebrew formula, TOML configuration, and 400 ms over the full history of this repository. |
| **trufflehog** | Chosen for audits only. It verifies a finding against the live provider, which no other tool here does. The binary is 117 MB and it makes network calls, so it is wrong for a hook. |
| **ggshield** | Rejected. It needs a GitGuardian account and an API token. A secret scanner that adds a secret to manage is a poor trade for a personal repository, and the free tier is capped. |
| **betterleaks** | Rejected for now. The Expr filters and the HTTP and LLM validation are a real advance over gitleaks. The project is young, and a second configuration dialect costs more than it returns here. |

## Four layers, because each one has a hole

No single control covers every path a secret takes into the repository.

1. **GitHub push protection** rejects recognized provider tokens at the
   server. Three paths skip the hook and not this layer: another machine, a
   web edit, and `--no-verify`. It knows nothing about generic keys.
2. **The pre-commit hook** scans the staged diff with gitleaks. It catches
   generic patterns that push protection misses, and it catches them before
   the secret leaves the machine. A committer who passes `--no-verify` skips
   it.
3. **The CI workflow** scans the full history on every push and every pull
   request. It is the backstop for anything the first two layers miss, and
   nobody can bypass it from a workstation.
4. **`secrets-audit --verify`** runs trufflehog on demand and reports which
   findings still authenticate. A live secret needs rotation now. A dead one
   needs a line in `.gitleaksignore`. This is also the periodic check:
   detection rules improve, so history that scans clean today can produce a
   finding next year.

## The gate is machine-wide, not repository-local

`core.hooksPath` is declared in `xdg_config/git/config`, so the hook runs in
every repository on this machine. Dotfiles is not where the worst secret will
land. Work clones and agent worktrees are.

Three constraints follow from that choice, and the hook handles each one.

- `core.hooksPath` replaces `.git/hooks` completely, so a repository's own
  pre-commit hook stops running. The global hook chains to it first, which
  also lets a formatter restage files before the scan reads them.
- `--config` and `GITLEAKS_CONFIG` both outrank a repository-local
  `.gitleaks.toml`. If the repository has a configuration of its own, the
  hook passes no global baseline, so a project keeps its own rules.
- GUI git clients start with a minimal PATH that omits Homebrew. The hook
  prepends the Homebrew directories itself.

If gitleaks is absent, the hook prints a warning and permits the commit. A
gate that blocks every commit on a new machine gets disabled within the hour,
and a disabled gate protects nothing. Findings still block.

Repositories that set `core.hooksPath` locally, such as those that use husky
or lefthook, keep their own tooling and lose the gate. Local git configuration
always beats global. Run `secrets-audit --hooks` to list them.

## What the first scan found

One real leak. A `HOMEBREW_GITHUB_API_TOKEN` sits in the first two commits of
January 2016. trufflehog checked it against the GitHub API on 2026-08-22 and
it does not authenticate. GitHub detected the same token on 2023-09-24 and
opened alert 1, which nobody read for three years.

One false positive. The GPG `signingkey` in `xdg_config/git/config` is public
key material. An allowlist in `.gitleaks.toml` covers it.

No leaked personal data. The tracked files hold two of the owner's own email
addresses, which the commit history already publishes, and no public IP
addresses or internal hostnames.

## We did not rewrite history

The 2016 token is inert. A rewrite changes every commit SHA from the initial
commit onward, breaks ten branches and one fork, and invalidates every
existing clone. That is a large cost to remove a credential that already does
nothing. The two findings are suppressed by fingerprint in `.gitleaksignore`,
with the reason recorded next to them.

CAUTION: Do not add a fingerprint to `.gitleaksignore` for a secret that still
authenticates. Rotate it first. The file records dead credentials and proven
false positives, and nothing else.

## Consequences

- `brewfiles/Brewfile` declares gitleaks and trufflehog. A machine without
  them has no gate, and the hook says so on every commit.
- New machines get the gate from `./run-dotbot`, which links
  `xdg_config/git` and `xdg_config/gitleaks`.
  `zsh-setup-scripts/gitleaks/install.sh` reports whether the wiring is
  correct. It is whitelisted in `allowed_installer_paths`, without which
  `install-all` skips it in silence.
- `core.hooksPath` uses `~/.config/git/hooks`, not an absolute path. Git
  expands the tilde. `git config --global` writes an absolute
  `/Users/<name>` path into this tracked file, so do not set the value that
  way.
- The CI workflow runs on push and pull request only. A schedule is wrong
  here for two reasons. GitHub runs a scheduled workflow only from the
  default branch, and GitHub disables one in a public repository after 60
  days without activity. This repository records 2 commits in all of 2023.
  In a quiet year like that one, the scan switches itself off and reports
  nothing. A control that stops in silence is worse than no control, because
  the owner still counts on it.
- GitHub validity checks and non-provider patterns stay off. Both need paid
  Secret Protection, and the API accepts the request to enable them without
  effect. The CI workflow covers the non-provider gap.
- Ten ShellSpec examples in `spec/secret_scanning/` drive the real hook
  through real commits. If the gate stops running, they fail. A unit test of
  the script alone cannot detect that.
