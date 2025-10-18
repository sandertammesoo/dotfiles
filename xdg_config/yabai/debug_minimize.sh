#!/usr/bin/env zsh

# Helper script to debug minimize/deminimize behavior

LOG_FILE="/tmp/yabai_minimize_debug.log"

case "${1:-tail}" in
    clear)
        echo "Clearing debug log..."
        rm -f "$LOG_FILE"
        echo "Log cleared. Start reproducing the bug now."
        ;;
    tail)
        echo "Monitoring minimize/deminimize events (Ctrl+C to stop)..."
        echo "=================================================="
        touch "$LOG_FILE"
        tail -f "$LOG_FILE"
        ;;
    show)
        if [[ -f "$LOG_FILE" ]]; then
            echo "Recent minimize/deminimize events:"
            echo "=================================================="
            cat "$LOG_FILE"
        else
            echo "No debug log found. Reproduce the bug first."
        fi
        ;;
    count)
        if [[ -f "$LOG_FILE" ]]; then
            echo "Event Summary:"
            echo "=================================================="
            echo "MINIMIZED events:     $(grep -c 'MINIMIZED:' "$LOG_FILE" 2>/dev/null || echo 0)"
            echo "DEMINIMIZED events:   $(grep -c 'DEMINIMIZED:' "$LOG_FILE" 2>/dev/null || echo 0)"
            echo "FOCUSED events:       $(grep -c 'FOCUSED:' "$LOG_FILE" 2>/dev/null || echo 0)"
            echo "APP SWITCHED events:  $(grep -c 'APP SWITCHED:' "$LOG_FILE" 2>/dev/null || echo 0)"
            echo ""
            echo "Unique apps involved:"
            grep -o '([^)]*)' "$LOG_FILE" | sort -u
        else
            echo "No debug log found."
        fi
        ;;
    apps)
        if [[ -f "$LOG_FILE" ]]; then
            echo "Currently minimized windows per app:"
            echo "=================================================="
            yabai -m query --windows | jq -r '.[] | select(.["is-minimized"] == true) | "\(.app): window \(.id) on space \(.space)"' | sort
        else
            echo "No debug log found."
        fi
        ;;
    help|*)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  tail    - Monitor debug log in real-time (default)"
        echo "  clear   - Clear the debug log and start fresh"
        echo "  show    - Show all logged events"
        echo "  count   - Show summary statistics"
        echo "  apps    - Show currently minimized windows"
        echo "  help    - Show this help message"
        echo ""
        echo "To reproduce the bug:"
        echo "  1. Run: $0 clear"
        echo "  2. Minimize several windows from different apps"
        echo "  3. In another terminal, run: $0 tail"
        echo "  4. Click dock or use Cmd+Tab to focus a minimized window"
        echo "  5. Watch the log to see which windows deminimize"
        ;;
esac
