# hq-sql caches 1Password credentials on disk

`hq-sql` reads five connection fields from a 1Password item at every run. The
1Password desktop app integration authorizes each new **process**, not each
terminal. Every agent `Bash` call is a new process, so the documented
10-minute sliding session never applies to an agent. An agent that runs ten
queries asks the owner for Touch ID ten times.

We cache the five fields in a `0600` file under `$XDG_CACHE_HOME/hq-sql/`. A
fresh cache answers the next run with no call to `op`.

## Why a cache and not the alternatives

| Option | Verdict |
|---|---|
| **Credential cache** | Chosen. The exposure is bounded by two clocks and the file is deleted on demand. It needs no change outside `hq-sql`. |
| **1Password service account** | Rejected as the default. The token grants unattended access with no expiry and lives in the shell environment. A one-hour cache is a smaller exposure than a permanent token. Service accounts also cannot read Employee vaults, so the items need a new shared vault first. `OP_SERVICE_ACCOUNT_TOKEN` keeps the path open for a headless machine. |
| **macOS Keychain** | Rejected. The login keychain is unlocked while the owner is logged in, and `security find-generic-password` succeeds with no prompt. The gain over a `0600` file is file permissions alone. The cost is a second credential store to audit and delete. |
| **Credential agent in memory** | Rejected for now. Nothing reaches disk, which is a real gain. A daemon with a socket and a lifecycle is more machinery than this problem earns. If the disk copy becomes a problem, revisit it. |
| **Fewer, larger queries** | Rejected as the only measure. Fewer calls reduce the count of prompts and never reach zero. |

## The cache is not the harlequin profile

`hq-sql` still builds an ephemeral TOML profile at every run and deletes it on
exit. The persistent cache holds values, not the profile. A future reader will
propose to keep the generated profile instead. Three facts block it.

- The profile carries the private IP address that `dig` resolved. The cache
  must not carry it, because the address changes. TOML forbids a second
  definition of a key, so a per-run `host` override line makes the file
  invalid.
- The profile starts as a copy of `xdg_config/harlequin/config.toml`. A
  persistent copy hides every later edit to the theme, the default profile,
  and the keybindings until the cache expires.
- Each run gets a private snapshot. One run reads a shared profile file while
  another run rewrites it.

`jq` is already a dependency of `hq-sql`, so JSON costs nothing to read back.

## Freshness has two clocks

A cache hit needs both clocks to pass.

- **Idle window.** The file mtime records the last use, and a hit touches it.
  Staging permits 60 minutes. Production permits 15 minutes.
- **Fetch ceiling.** The `fetched_at` field inside the file records the read
  from 1Password. Both environments permit 8 hours.

The idle window means a long work session never asks again. The fetch ceiling
means an idle machine does not hold credentials all week. Production gets the
shorter idle window because production queries are rare. Touch ID on a rare
query is not the friction this decision removes.

CAUTION: Do not read the age of the fetch from the file mtime. A cache hit
touches the mtime, so the mtime measures the last use only.

## Consequences

- The cache holds a production database password in cleartext for up to 8
  hours. Any process that runs as this user can read it. Touch ID no longer
  gates each query. The credentials are SELECT-only, which bounds the damage
  to disclosure.
- The cache key includes the 1Password account and vault, not the environment
  name alone. `HQ_SQL_OP_VAULT` selects the vault, so a key of the
  environment name serves credentials that came from a different vault.
- The cache holds the five fields only. The 1Password item carries more
  fields, and none of them belong on disk.
- When `OP_SERVICE_ACCOUNT_TOKEN` is set, the cache is bypassed completely.
  That path has no prompt, so a disk copy adds risk and returns nothing.
- A cache file that is not a 0600 file owned by this user is refused. Its
  `host` and `password` steer the connection, so ownership is not optional.
  The directory mode is set by the script, not by the `dotbot` entry, which
  cannot carry a mode.
- `HQ_SQL_CACHE_DIR` moves the whole cache. `HQ_SQL_LOCK_WAIT` and
  `HQ_SQL_LOCK_STALE` set the lock timings. The tests need all three.
- Two parallel agent calls on a cold cache produce two prompts and a torn
  file. A `mkdir` lock makes the loser wait for the winner. If the wait
  reaches 30 seconds, the loser reads 1Password itself. A lock older than 60
  seconds is broken, because a crashed run must not wedge every later call.
- `--refresh` and `--forget` are parsed before the environment argument.
  Parsed after it, they reach `hsql` and fail. `--forget` deletes the whole
  cache and needs no environment.
- An authentication error deletes the cache, reads 1Password once, and runs
  again. A failure of the `nc` reachability check does not. Every Tailscale
  outage otherwise turns into a prompt.
- Nothing about the cache prints on stdout. An agent parses `--json` output
  from stdout, and a status line corrupts it. `HQ_SQL_DEBUG=1` prints hit and
  miss to stderr.
- The headless path buffers the runner's stderr into a temporary file and
  replays it after the run. The retry must read the error text. The cost is
  that stderr no longer interleaves with stdout as the query runs.
- Two callers never retry. The TUI is interactive, so the user reads the
  error and reruns with `--refresh`. A call that takes its script from stdin
  (`-f -`) cannot repeat the run, because the first attempt drained stdin.
  hq-sql says so and names `--refresh`.
- `dotbot.conf.yaml` creates `$XDG_CACHE_HOME/hq-sql` with the other cache
  directories.
- ShellSpec examples in `spec/harlequin/` drive the real script with stub
  `op`, `dig`, `nc`, and `hsql` commands on `PATH`. The fixtures hold invented
  passwords. The `^spec/` allowlist already in `.gitleaks.toml` covers them,
  because every fixture secret contains the word `dummy`. A new fixture must
  keep that property. A fingerprint in `.gitleaksignore` is wrong here.
  When a line number moves, the fingerprint stops matching.
