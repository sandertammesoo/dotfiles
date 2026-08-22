#!/usr/bin/env zsh
#
# Audit helpers for the secret-scanning setup.
#
# The pre-commit hook and GitHub push protection stop new secrets. These
# functions answer the other two questions: what is already in history, and
# where does the gate not apply?

if ! command -v gitleaks &> /dev/null; then
    log_skip "gitleaks not found, skipping secrets-audit functions"
    return
fi

# secrets-audit [--hooks] [--verify] [path]
#
#   (no flags)  scan the full history of the repo at [path] with gitleaks
#   --verify    additionally run trufflehog, which live-checks each candidate
#               against its provider to tell a dead credential from a live one
#   --hooks     report repositories whose local core.hooksPath overrides the
#               global gate, and whether the global gate is installed at all
secrets-audit() {
    emulate -L zsh
    setopt local_options no_unset

    local do_hooks=false do_verify=false target=""

    while (( $# )); do
        case "$1" in
            --hooks)  do_hooks=true ;;
            --verify) do_verify=true ;;
            -h|--help)
                print "usage: secrets-audit [--verify] [--hooks] [path]"
                return 0 ;;
            *) target="$1" ;;
        esac
        shift
    done

    if [[ "$do_hooks" == "true" ]]; then
        _secrets_audit_hooks
        return $?
    fi

    target="${target:-$PWD}"

    if ! git -C "$target" rev-parse --git-dir &> /dev/null; then
        print -u2 "secrets-audit: not a git repository: $target"
        return 2
    fi

    print "── gitleaks: full history of $(basename "$target") ──"
    gitleaks git --log-opts="--all" --no-banner --redact=40 "$target"
    local gl_status=$?

    if [[ "$do_verify" == "true" ]]; then
        if ! command -v trufflehog &> /dev/null; then
            print -u2 "secrets-audit: trufflehog not installed (brew install trufflehog)"
            return $gl_status
        fi
        print "\n── trufflehog: live verification ──"

        # --results=verified,unknown drops findings trufflehog proved dead, so
        # anything printed here either still authenticates or could not be
        # checked. Progress logging goes to stderr and is discarded.
        local -a hits
        hits=("${(@f)$(trufflehog git "file://${target}" --no-update \
            --results=verified,unknown --json 2> /dev/null)}")
        hits=(${hits:#})

        if (( ${#hits} == 0 )); then
            print "No live or unverifiable secrets. Findings suppressed as dead stay dead."
        else
            print "${#hits} finding(s) that still authenticate or could not be checked."
            print "Rotate a verified secret now, before anything else.\n"
            printf '%s\n' "${hits[@]}" | jq -r '
                "  \(.DetectorName)  verified=\(.Verified)  " +
                "\(.SourceMetadata.Data.Git.file):\(.SourceMetadata.Data.Git.line)  " +
                "@\(.SourceMetadata.Data.Git.commit[0:10])"' 2> /dev/null \
                || printf '%s\n' "${hits[@]}"
        fi
    fi

    return $gl_status
}

# Repositories that set core.hooksPath locally (husky, lefthook, custom) do not
# get the global gate: local git config always beats global. They are not
# broken, they are simply unguarded, and worth knowing about.
_secrets_audit_hooks() {
    emulate -L zsh
    local -a roots
    roots=(${SECRETS_AUDIT_ROOTS:-$HOME/projects})

    # Read the effective value, not --global: core.hooksPath is declared in the
    # tracked xdg_config/git/config. Git expands a leading ~ when it runs hooks,
    # so expand it here too before testing the path.
    local configured resolved
    configured="$(git config --get core.hooksPath)"
    resolved="${configured/#\~/$HOME}"

    if [[ -z "$configured" ]]; then
        print "✗ core.hooksPath is unset — no machine-wide gate"
    elif [[ -x "${resolved}/pre-commit" ]]; then
        print "✓ global gate active: ${resolved}/pre-commit"
    else
        print "✗ core.hooksPath is ${configured} but holds no executable pre-commit"
    fi

    print "\nRepositories overriding it (unguarded):"
    local found=0 repo local_path
    for repo in ${^roots}/*/.git(N/,@); do
        repo="${repo:h}"
        local_path="$(git -C "$repo" config --local --get core.hooksPath)"
        if [[ -n "$local_path" ]]; then
            print "  ${repo:t}  →  ${local_path}"
            (( found++ ))
        fi
    done
    (( found == 0 )) && print "  (none)"

    print "\nSearched: ${roots[*]}  (override with SECRETS_AUDIT_ROOTS)"
}
