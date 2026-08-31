# shellcheck shell=zsh
# ShellSpec tests for the hq-sql credential cache.
#
# Each test drives the real script with stub `op`, `dig`, `nc` and `hsql`
# commands on PATH, because the properties that matter are end-to-end:
# how many times 1Password is read, what lands on disk, and with which
# permissions. A unit test of a cache function cannot see any of that.
#
# Every invented secret below must contain the word "dummy". The repo's
# .gitleaks.toml allowlists spec/ only for secrets matching that pattern
# list, so a fixture named otherwise can block a commit.
#
# See docs/adr/0003-hq-sql-credential-cache.md.

Describe 'hq-sql credential cache'
  HQ_SQL_SOURCE="xdg_config/harlequin/scripts/hq-sql"

  setup() {
    REPO_ROOT="$PWD"
    HQ_SQL="${REPO_ROOT}/${HQ_SQL_SOURCE}"
    TEST_DIR="$(mktemp -d)"

    export STUB_STATE="${TEST_DIR}/state"
    mkdir -p "$STUB_STATE"

    # A private cache and a private XDG tree, so no test reads or writes
    # the real credential cache or the real harlequin config.
    export HQ_SQL_CACHE_DIR="${TEST_DIR}/cache"
    export XDG_CONFIG_HOME="${TEST_DIR}/xdg"
    mkdir -p "${XDG_CONFIG_HOME}/harlequin"
    # hq-sql and the stubs run under `env zsh`, which reads $ZDOTDIR/.zshenv.
    # An empty ZDOTDIR keeps the real shell configuration out of the tests.
    export ZDOTDIR="${TEST_DIR}/zdotdir"
    mkdir -p "$ZDOTDIR"
    printf 'default_profile = "none"\n' > "${XDG_CONFIG_HOME}/harlequin/config.toml"

    unset OP_SERVICE_ACCOUNT_TOKEN HQ_SQL_CACHE_TTL HQ_SQL_CACHE_MAX_AGE
    unset HQ_SQL_DEBUG HQ_SQL_OP_VAULT
    # Keep the lock waits short, or a lock test would take 30 seconds.
    export HQ_SQL_LOCK_WAIT=2
    export HQ_SQL_LOCK_STALE=5
    export STUB_HSQL_MODE="ok"
    export STUB_NC_EXIT=0
    export STUB_OP_EXIT=0

    make_stubs
    export PATH="${TEST_DIR}/bin:${PATH}"
  }

  cleanup() {
    rm -rf "$TEST_DIR"
  }

  Before 'setup'
  After 'cleanup'

  make_stubs() {
    local bin="${TEST_DIR}/bin"
    mkdir -p "$bin"

    # The item carries a field beyond the five on purpose: nothing but the
    # five may reach the cache file.
    cat > "${TEST_DIR}/item.json" <<'JSON'
{
  "id": "fixture",
  "title": "fixture item",
  "fields": [
    {"id": "hostname", "value": "api-db.staging"},
    {"id": "port", "value": "3306"},
    {"id": "database", "value": "fractory"},
    {"id": "username", "value": "dummy.user"},
    {"id": "password", "value": "dummy-fixture-pw"},
    {"id": "notesPlain", "value": "dummy-note-must-not-reach-disk"}
  ]
}
JSON

    cat > "${bin}/op" <<STUB
#!/usr/bin/env zsh
print -r -- "\$*" >> "\$STUB_STATE/op_calls"
if [[ "\${STUB_OP_EXIT:-0}" != "0" ]]; then
    print -u2 "op: stub failure"
    exit "\$STUB_OP_EXIT"
fi
cat "${TEST_DIR}/item.json"
STUB

    cat > "${bin}/dig" <<'STUB'
#!/usr/bin/env zsh
# MagicDNS answers with the private address inside the VPC.
print -r -- "10.20.30.40"
STUB

    cat > "${bin}/nc" <<'STUB'
#!/usr/bin/env zsh
exit "${STUB_NC_EXIT:-0}"
STUB

    cat > "${bin}/hsql" <<'STUB'
#!/usr/bin/env zsh
print -r -- "$*" >> "$STUB_STATE/hsql_args"
cfg="" prev=""
for a in "$@"; do
    [[ "$prev" == "--config-path" ]] && cfg="$a"
    prev="$a"
done
[[ -n "$cfg" ]] && cp "$cfg" "$STUB_STATE/last_config"
case "${STUB_HSQL_MODE:-ok}" in
    authfail)
        # Fail once, so a retry with fresh credentials can succeed.
        if [[ -f "$STUB_STATE/authfail_armed" ]]; then
            rm -f "$STUB_STATE/authfail_armed"
            print -u2 "ERROR: 1045 (28000): Access denied for user 'dummy.user'@'host'"
            exit 1
        fi
        ;;
    sqlerror)
        print -u2 "ERROR 1064 (42000): You have an error in your SQL syntax"
        exit 1
        ;;
esac
print -r -- "query-ok"
STUB

    cp "${bin}/hsql" "${bin}/harlequin"
    chmod +x "${bin}"/*
  }

  # --- helpers ---------------------------------------------------------

  hq() { "$HQ_SQL" "$@"; }

  run_query() { "$HQ_SQL" "$@" -c "SELECT 1" > /dev/null 2>&1; }

  op_calls() {
    if [[ -f "$STUB_STATE/op_calls" ]]; then
      print -r -- "$(wc -l < "$STUB_STATE/op_calls" | tr -d ' ')"
    else
      print -r -- 0
    fi
  }

  cache_file() {
    local -a f
    f=("$HQ_SQL_CACHE_DIR"/*(.N))
    print -r -- "${f[1]:-}"
  }

  cache_count() {
    local -a f
    f=("$HQ_SQL_CACHE_DIR"/*(.N))
    print -r -- ${#f}
  }

  mode_of() { stat -f %Lp "$1"; }

  # Move a file's mtime back by N seconds.
  backdate() { touch -t "$(date -v-"${2}"S +%Y%m%d%H%M.%S)" "$1"; }

  # Rewrite fetched_at while leaving the mtime fresh.
  set_fetched_at() {
    local f tmp
    f="$(cache_file)"
    tmp="${f}.rewrite"
    jq --argjson t "$1" '.fetched_at = $t' < "$f" > "$tmp"
    mv -f "$tmp" "$f"
  }

  warm_cache() { run_query staging; }

  # --- cold and warm ---------------------------------------------------

  Describe 'first run'
    It 'reads 1Password once and writes one cache file'
      run_query staging
      When call cache_count
      The output should equal 1
    End

    It 'reads 1Password exactly once'
      run_query staging
      When call op_calls
      The output should equal 1
    End

    It 'writes the cache file with mode 600'
      run_query staging
      When call mode_of "$(cache_file)"
      The output should equal 600
    End

    It 'writes the cache directory with mode 700'
      run_query staging
      When call mode_of "$HQ_SQL_CACHE_DIR"
      The output should equal 700
    End

    It 'caches the five connection fields and fetched_at, and nothing else'
      run_query staging
      When call jq -r 'keys | join(",")' "$(cache_file)"
      The output should equal "database,fetched_at,host,password,port,user"
    End

    It 'keeps the other fields of the 1Password item off disk'
      run_query staging
      When call grep -c "must-not-reach-disk" "$(cache_file)"
      The status should be failure
      The output should equal 0
    End
  End

  Describe 'a fresh cache'
    It 'does not read 1Password again'
      warm_cache
      run_query staging
      When call op_calls
      The output should equal 1
    End

    It 'still passes the resolved private address to the runner'
      warm_cache
      run_query staging
      When call grep -c "host = '10.20.30.40'" "$STUB_STATE/last_config"
      The output should equal 1
    End

    It 'stores the DNS name, not the resolved address'
      warm_cache
      When call jq -r '.host' "$(cache_file)"
      The output should equal "api-db.staging"
    End

    It 'picks up an edit to the harlequin config on the next run'
      warm_cache
      printf 'default_profile = "edited-after-the-cache"\n' \
        > "${XDG_CONFIG_HOME}/harlequin/config.toml"
      run_query staging
      When call grep -c "edited-after-the-cache" "$STUB_STATE/last_config"
      The output should equal 1
    End
  End

  # --- the two clocks --------------------------------------------------

  Describe 'the idle window'
    It 'expires and reads 1Password again'
      warm_cache
      backdate "$(cache_file)" 3700
      run_query staging
      When call op_calls
      The output should equal 2
    End

    It 'is extended by a cache hit'
      export HQ_SQL_CACHE_TTL=120
      warm_cache
      backdate "$(cache_file)" 90
      run_query staging   # a hit, which touches the mtime
      backdate "$(cache_file)" 90
      run_query staging   # still a hit, because the touch reset the clock
      When call op_calls
      The output should equal 1
    End

    It 'is shorter for production than for staging'
      export HQ_SQL_CACHE_MAX_AGE=28800
      run_query staging
      run_query prod
      for f in "$HQ_SQL_CACHE_DIR"/*(.N); do backdate "$f" 1800; done
      run_query staging   # inside the 3600s staging window
      run_query prod      # outside the 900s production window
      When call op_calls
      The output should equal 3
    End
  End

  Describe 'the fetch ceiling'
    It 'outranks a freshly touched mtime'
      warm_cache
      set_fetched_at $(( $(date +%s) - 40000 ))
      run_query staging
      When call op_calls
      The output should equal 2
    End

    It 'is configurable'
      export HQ_SQL_CACHE_MAX_AGE=10
      warm_cache
      set_fetched_at $(( $(date +%s) - 60 ))
      run_query staging
      When call op_calls
      The output should equal 2
    End
  End

  # --- flags -----------------------------------------------------------

  Describe '--refresh'
    It 'ignores a fresh cache and reads 1Password'
      warm_cache
      run_query --refresh staging
      When call op_calls
      The output should equal 2
    End

    It 'is forwarded to the runner when it comes after the environment'
      run_query staging --refresh
      When call grep -c -- "--refresh" "$STUB_STATE/hsql_args"
      The output should equal 1
    End
  End

  Describe '--forget'
    It 'deletes the cache and exits 0'
      warm_cache
      When call hq --forget
      The status should be success
      The stdout should equal ""
      The stderr should include "credential cache deleted"
    End

    It 'leaves no cache behind'
      warm_cache
      hq --forget > /dev/null 2>&1
      When call test -d "$HQ_SQL_CACHE_DIR"
      The status should be failure
    End

    It 'needs no environment argument and tolerates no cache'
      When call hq --forget
      The status should be success
      The stderr should include "no credential cache"
    End
  End

  Describe 'usage'
    It 'rejects an unknown environment with exit 2'
      When call hq nonsense
      The status should equal 2
      The stderr should include "usage:"
    End
  End

  # --- the bypass ------------------------------------------------------

  Describe 'a service account token'
    It 'writes no cache file'
      export OP_SERVICE_ACCOUNT_TOKEN="dummy-service-account-token"
      run_query staging
      When call cache_count
      The output should equal 0
    End

    It 'reads 1Password on every run'
      export OP_SERVICE_ACCOUNT_TOKEN="dummy-service-account-token"
      run_query staging
      run_query staging
      When call op_calls
      The output should equal 2
    End
  End

  # --- the cache key ---------------------------------------------------

  Describe 'the cache key'
    It 'separates two vaults'
      HQ_SQL_OP_VAULT="VaultOne" run_query staging
      HQ_SQL_OP_VAULT="VaultTwo" run_query staging
      When call cache_count
      The output should equal 2
    End

    It 'separates staging from production'
      run_query staging
      run_query prod
      When call cache_count
      The output should equal 2
    End
  End

  # --- failure handling ------------------------------------------------

  Describe 'an authentication error with cached credentials'
    It 'reads 1Password once more and succeeds'
      warm_cache
      export STUB_HSQL_MODE="authfail"
      touch "$STUB_STATE/authfail_armed"
      run_query staging
      When call op_calls
      The output should equal 2
    End

    It 'returns success after the retry'
      warm_cache
      export STUB_HSQL_MODE="authfail"
      touch "$STUB_STATE/authfail_armed"
      When call run_query staging
      The status should be success
    End
  End

  Describe 'a SQL error with cached credentials'
    It 'does not read 1Password again'
      warm_cache
      export STUB_HSQL_MODE="sqlerror"
      run_query staging || true
      When call op_calls
      The output should equal 1
    End

    It 'fails'
      warm_cache
      export STUB_HSQL_MODE="sqlerror"
      When call run_query staging
      The status should be failure
    End
  End

  Describe 'an unreachable host'
    It 'never reaches the authentication retry'
      warm_cache
      export STUB_NC_EXIT=1
      run_query staging || true
      When call op_calls
      The output should equal 1
    End

    It 'names Tailscale in the error'
      warm_cache
      export STUB_NC_EXIT=1
      When call hq staging -c "SELECT 1"
      The status should be failure
      The stderr should include "Tailscale"
    End
  End

  Describe 'a 1Password failure'
    It 'fails without writing a cache file'
      export STUB_OP_EXIT=1
      run_query staging || true
      When call cache_count
      The output should equal 0
    End
  End

  Describe 'a cache missing a connection field'
    # The rewrite must be chmod'd back to 600, or the ownership check
    # rejects the file first and the test passes for the wrong reason.
    drop_password() {
      local f
      f="$(cache_file)"
      jq 'del(.password)' < "$f" > "${f}.rewrite"
      mv -f "${f}.rewrite" "$f"
      chmod 600 "$f"
    }

    It 'falls back to 1Password'
      warm_cache
      drop_password
      run_query staging
      When call op_calls
      The output should equal 2
    End

    It 'names the field that is missing'
      warm_cache
      drop_password
      When call hq staging -c "SELECT 1"
      The status should be success
      The stderr should include "missing the password field"
      The stdout should equal "query-ok"
    End
  End

  Describe 'a corrupted cache'
    It 'falls back to 1Password'
      warm_cache
      printf 'not json at all\n' > "$(cache_file)"
      run_query staging
      When call op_calls
      The output should equal 2
    End
  End

  # --- the lock --------------------------------------------------------

  Describe 'the cold-cache lock'
    It 'is released after a successful run'
      run_query staging
      When call test -d "${HQ_SQL_CACHE_DIR}/.lock"
      The status should be failure
    End

    It 'breaks a lock left behind by a crashed run'
      mkdir -p "${HQ_SQL_CACHE_DIR}/.lock"
      backdate "${HQ_SQL_CACHE_DIR}/.lock" 30
      run_query staging
      When call op_calls
      The output should equal 1
    End

    It 'leaves no broken lock behind'
      mkdir -p "${HQ_SQL_CACHE_DIR}/.lock"
      backdate "${HQ_SQL_CACHE_DIR}/.lock" 30
      run_query staging
      When call test -d "${HQ_SQL_CACHE_DIR}/.lock"
      The status should be failure
    End

    It 'gives up on a live lock and reads 1Password anyway'
      # A lock young enough to be live, held by nobody who will finish it.
      mkdir -p "${HQ_SQL_CACHE_DIR}/.lock"
      print -r -- "someone-else" > "${HQ_SQL_CACHE_DIR}/.lock/owner"
      run_query staging
      When call op_calls
      The output should equal 1
    End

    It 'does not release a lock that belongs to another run'
      mkdir -p "${HQ_SQL_CACHE_DIR}/.lock"
      print -r -- "someone-else" > "${HQ_SQL_CACHE_DIR}/.lock/owner"
      run_query staging
      When call cat "${HQ_SQL_CACHE_DIR}/.lock/owner"
      The output should equal "someone-else"
    End
  End

  # --- the TUI ---------------------------------------------------------

  Describe 'the TUI'
    It 'warms the same cache as a headless run'
      run_query --tui staging
      When call cache_count
      The output should equal 1
    End

    It 'reads a cache a headless run wrote'
      warm_cache
      run_query --tui staging
      When call op_calls
      The output should equal 1
    End
  End

  # --- trust -----------------------------------------------------------

  Describe 'a cache file with the wrong permissions'
    It 'is refused, and 1Password is read again'
      warm_cache
      chmod 644 "$(cache_file)"
      run_query staging
      When call op_calls
      The output should equal 2
    End
  End

  Describe 'a consumed stdin'
    It 'blocks the authentication retry and says why'
      warm_cache
      export STUB_HSQL_MODE="authfail"
      touch "$STUB_STATE/authfail_armed"
      When call sh -c "printf 'SELECT 1\\n' | '$HQ_SQL' staging -f -"
      The status should be failure
      The stderr should include "rerun with --refresh"
    End

    It 'does not read 1Password again'
      warm_cache
      export STUB_HSQL_MODE="authfail"
      touch "$STUB_STATE/authfail_armed"
      printf 'SELECT 1\n' | "$HQ_SQL" staging -f - > /dev/null 2>&1 || true
      When call op_calls
      The output should equal 1
    End
  End

  Describe '--forget with several environments cached'
    It 'deletes every one'
      run_query staging
      run_query prod
      hq --forget > /dev/null 2>&1
      When call test -d "$HQ_SQL_CACHE_DIR"
      The status should be failure
    End
  End

  # --- output discipline -----------------------------------------------

  Describe 'output'
    It 'says nothing about the cache on stdout'
      warm_cache
      When call hq staging -c "SELECT 1"
      The status should be success
      The stdout should equal "query-ok"
    End

    It 'reports a hit on stderr under HQ_SQL_DEBUG'
      warm_cache
      export HQ_SQL_DEBUG=1
      When call hq staging -c "SELECT 1"
      The status should be success
      The stderr should include "cache hit"
      The stdout should equal "query-ok"
    End

    It 'reports a miss on stderr under HQ_SQL_DEBUG'
      warm_cache
      backdate "$(cache_file)" 3700
      export HQ_SQL_DEBUG=1
      When call hq staging -c "SELECT 1"
      The status should be success
      The stderr should include "idle window"
      The stdout should equal "query-ok"
    End
  End
End
