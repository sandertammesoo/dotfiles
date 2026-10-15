# shellcheck shell=zsh
# ShellSpec tests for the browser opacity signals in xdg_config/yabai/yabairc.
#
# yabairc runs against a stub `yabai` that saves each labelled signal action to
# a file, so the tests run the generated action scripts without a live yabai.
# Guard: a window_focused signal with no app= filter must never run a global
# `query --windows` (CLAUDE.md "Yabai": it deminimizes windows system-wide).

Describe 'yabairc browser opacity signals'
  setup() {
    REPO_ROOT="$PWD"
    TEST_DIR="$(mktemp -d)"
    export OUT="$TEST_DIR"
    mkdir -p "$TEST_DIR/bin" "$TEST_DIR/actions" "$TEST_DIR/tmp"

    cat > "$TEST_DIR/bin/yabai" <<'EOF'
#!/bin/sh
if [ "$1 $2" = "-m signal" ]; then
  label="" action="" event="" app=""
  for a in "$@"; do
    case "$a" in
      label=*) label=${a#label=} ;;
      action=*) action=${a#action=} ;;
      event=*) event=${a#event=} ;;
      app=*) app=yes ;;
    esac
  done
  [ -n "$label" ] && printf '%s' "$action" > "$OUT/actions/$label.sh"
  case "$action" in *"query --windows"*)
    [ "$event" = window_focused ] && [ -z "$app" ] && printf '%s\n' "${label:-unlabelled}" >> "$OUT/violations"
  esac
  exit 0
fi
printf '%s\n' "$*" >> "$OUT/calls.log"
case "$*" in *"query --windows --window"*) printf '{"title":"%s"}\n' "$STUB_TITLE" ;; esac
exit 0
EOF
    printf '#!/bin/sh\nexit 0\n' > "$TEST_DIR/bin/sudo"
    chmod +x "$TEST_DIR/bin/yabai" "$TEST_DIR/bin/sudo"

    PATH="$TEST_DIR/bin:$PATH" sh "$REPO_ROOT/xdg_config/yabai/yabairc" >/dev/null 2>&1
    rm -f "$TEST_DIR/calls.log"
    STATE="$TEST_DIR/tmp/yabai_opacity_focus_ids"
  }

  cleanup() { rm -rf "$TEST_DIR"; }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  run_action() { # label app window_id [title]
    PATH="$TEST_DIR/bin:$PATH" TMPDIR="$TEST_DIR/tmp" YABAI_WINDOW_APP="$2" \
      YABAI_WINDOW_ID="$3" STUB_TITLE="${4:-}" sh "$TEST_DIR/actions/$1.sh"
  }
  calls() { cat "$TEST_DIR/calls.log" 2>/dev/null; }

  It 'has no app-unfiltered window_focused signal that queries windows'
    The path "$TEST_DIR/violations" should not be exist
  End

  It 'generates syntactically valid opacity action scripts'
    check_syntax() {
      for f in "$TEST_DIR"/actions/opacity_*.sh; do sh -n "$f" || return 1; done
    }
    When call check_syntax
    The status should be success
  End

  Describe 'reset action'
    It 'resets only recorded IDs, without a window query, and clears the record'
      printf '11\n22\n' > "$STATE"
      When call run_action opacity_browser_focus_reset Slack 99
      The status should be success
      The result of function calls should include "-m window 11 --opacity 0.0"
      The result of function calls should include "-m window 22 --opacity 0.0"
      The result of function calls should not include "query"
      The path "$STATE" should not be exist
    End

    It 'does nothing when a browser gains focus'
      printf '11\n' > "$STATE"
      When call run_action opacity_browser_focus_reset "Brave Browser" 11
      The status should be success
      The path "$TEST_DIR/calls.log" should not be exist
      The path "$STATE" should be file
    End

    It 'does nothing when no window is recorded'
      When call run_action opacity_browser_focus_reset Slack 99
      The status should be success
      The path "$TEST_DIR/calls.log" should not be exist
    End
  End

  Describe 'focus action'
    It 'makes a focus-page window opaque and records its ID once'
      run_action opacity_brave_focus_focused "Brave Browser" 42 "Reddit - Brave"
      When call run_action opacity_brave_focus_focused "Brave Browser" 42 "Reddit - Brave"
      The result of function calls should include "-m window 42 --opacity 1.0"
      The contents of file "$STATE" should equal "42"
    End

    It 'drops the ID and resets opacity when the window leaves the focus pages'
      printf '42\n7\n' > "$STATE"
      When call run_action opacity_brave_focus_focused "Brave Browser" 42 "GitHub - Brave"
      The result of function calls should include "-m window 42 --opacity 0.0"
      The contents of file "$STATE" should equal "7"
    End

    It 'drops the ID but keeps always-opaque pages at their opacity'
      printf '42\n' > "$STATE"
      When call run_action opacity_brave_focus_focused "Brave Browser" 42 "YouTube - Brave"
      The result of function calls should not include "--opacity 0.0"
      The contents of file "$STATE" should equal ""
    End
  End
End
