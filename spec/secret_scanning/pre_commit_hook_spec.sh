# shellcheck shell=zsh
# ShellSpec tests for the machine-wide pre-commit secret gate.
#
# Each test drives the real hook through a real `git commit` in a throwaway
# repository, because the failure that matters is "the gate silently stopped
# running", and only an end-to-end commit can catch that.

Describe 'Pre-commit secret gate'
  HOOK_SOURCE="xdg_config/git/hooks/pre-commit"

  # Correctly formed but fabricated. Real enough for gitleaks' github-pat rule.
  FAKE_PAT='ghp_A1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6Q7r8'  # gitleaks:allow — fabricated fixture, never a real token

  setup() {
    REPO_ROOT="$PWD"
    TEST_DIR="$(mktemp -d)"

    # A private XDG tree so the tests never read or write the real config.
    export XDG_CONFIG_HOME="${TEST_DIR}/xdg"
    mkdir -p "${XDG_CONFIG_HOME}/git/hooks" "${XDG_CONFIG_HOME}/gitleaks"
    cp "${REPO_ROOT}/${HOOK_SOURCE}" "${XDG_CONFIG_HOME}/git/hooks/pre-commit"
    chmod +x "${XDG_CONFIG_HOME}/git/hooks/pre-commit"
    cp "${REPO_ROOT}/xdg_config/gitleaks/gitleaks.toml" "${XDG_CONFIG_HOME}/gitleaks/"

    REPO="${TEST_DIR}/repo"
    mkdir -p "$REPO"
    git -C "$REPO" init -q
    git -C "$REPO" config user.email "test@example.com"
    git -C "$REPO" config user.name "Test"
    git -C "$REPO" config core.hooksPath "${XDG_CONFIG_HOME}/git/hooks"

    unset GITLEAKS_SKIP
  }

  cleanup() {
    rm -rf "$TEST_DIR"
  }

  Before 'setup'
  After 'cleanup'

  stage_secret() {
    printf 'export GH_TOKEN=%s\n' "$FAKE_PAT" > "${REPO}/creds.sh"
    git -C "$REPO" add -A
  }

  stage_clean() {
    printf 'echo hello\n' > "${REPO}/ok.sh"
    git -C "$REPO" add -A
  }

  commit() { git -C "$REPO" commit -m "test" 2>&1; }

  Describe 'blocking'
    It 'rejects a commit containing a token'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      stage_secret
      When call commit
      The status should be failure
      The output should include "COMMIT BLOCKED"
    End

    It 'rejects a commit containing a private key'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      printf -- '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAvR8kL2mNp0QrStUvWxYz1234567890abcdefghijkl\n-----END RSA PRIVATE KEY-----\n' > "${REPO}/id_rsa"  # gitleaks:allow — fabricated fixture
      git -C "$REPO" add -A
      When call commit
      The status should be failure
      The output should include "COMMIT BLOCKED"
    End

    It 'tells the user to rotate the credential'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      stage_secret
      When call commit
      The status should be failure
      The output should include "Rotate the credential"
    End
  End

  Describe 'allowing'
    It 'permits a commit with no secret'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      stage_clean
      When call commit
      The status should be success
      The output should be present
    End
  End

  Describe 'opt-outs'
    It 'honours GITLEAKS_SKIP for a single commit'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      stage_secret
      export GITLEAKS_SKIP=1
      When call commit
      The status should be success
      The output should include "gitleaks skipped"
    End

    It 'honours a per-repository hooks.gitleaks=false'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      git -C "$REPO" config hooks.gitleaks false
      stage_secret
      When call commit
      The status should be success
      The output should be present
    End
  End

  Describe 'chaining to a repository hook'
    chained_setup() {
      mkdir -p "${REPO}/.git/hooks"
      printf '#!/bin/sh\necho REPO-HOOK-RAN\nexit %s\n' "$1" > "${REPO}/.git/hooks/pre-commit"
      chmod +x "${REPO}/.git/hooks/pre-commit"
    }

    It 'still runs a hook that core.hooksPath would otherwise replace'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      chained_setup 0
      stage_clean
      When call commit
      The status should be success
      The output should include "REPO-HOOK-RAN"
    End

    It 'aborts the commit when the repository hook fails'
      chained_setup 3
      stage_clean
      When call commit
      The status should be failure
      The output should include "REPO-HOOK-RAN"
    End
  End

  Describe 'configuration precedence'
    # --config and GITLEAKS_CONFIG both outrank a repo-local .gitleaks.toml,
    # so the hook must pass the global baseline only when the repository has
    # no config of its own. Otherwise a project's tuned rules vanish.
    It 'lets a repository .gitleaks.toml override the global baseline'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      printf 'title="local"\n[extend]\nuseDefault=true\ndisabledRules=["github-pat","generic-api-key"]\n' > "${REPO}/.gitleaks.toml"
      stage_secret
      When call commit
      The status should be success
      The output should be present
    End
  End

  Describe 'worktrees'
    It 'gates commits made inside a linked worktree'
      Skip if "gitleaks not installed" test -z "$(command -v gitleaks)"
      printf 'init\n' > "${REPO}/a.txt"
      git -C "$REPO" add -A
      git -C "$REPO" commit -qm init > /dev/null 2>&1
      git -C "$REPO" worktree add -q "${TEST_DIR}/wt" -b wt > /dev/null 2>&1
      printf 'export GH_TOKEN=%s\n' "$FAKE_PAT" > "${TEST_DIR}/wt/creds.sh"
      git -C "${TEST_DIR}/wt" add -A
      When call git -C "${TEST_DIR}/wt" commit -m "test"
      The status should be failure
      The stderr should include "COMMIT BLOCKED"
    End
  End
End
