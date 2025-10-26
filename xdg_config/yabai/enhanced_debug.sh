#!/usr/bin/env zsh

# Enhanced debug script to catch the minimize bug in action
LOG_FILE="/tmp/yabai_minimize_debug.log"
ENHANCED_LOG="/tmp/yabai_enhanced_debug.log"

echo "=== Enhanced Minimize Bug Investigation Started at $(date) ===" > "$ENHANCED_LOG"

# Monitor all Yabai events in real-time
echo "Starting enhanced monitoring..." >> "$ENHANCED_LOG"

# Function to log current window states
log_window_states() {
    echo "=== CURRENT WINDOW STATES at $(date '+%H:%M:%S.%3N') ===" >> "$ENHANCED_LOG"
    yabai -m query --windows | jq -r '.[] | "\(.id): \(.app) - minimized:\(.["is-minimized"]) space:\(.space)"' >> "$ENHANCED_LOG"
    echo "=== END WINDOW STATES ===" >> "$ENHANCED_LOG"
}

# Monitor the debug log for DEMINIMIZED events
tail -f "$LOG_FILE" | while read line; do
    if [[ "$line" == *"DEMINIMIZED"* ]]; then
        echo "🚨 DEMINIMIZE EVENT DETECTED: $line" >> "$ENHANCED_LOG"
        
        # Log current processes that might be interfering
        echo "=== ACTIVE PROCESSES at $(date '+%H:%M:%S.%3N') ===" >> "$ENHANCED_LOG"
        ps aux | grep -E "(osascript|Hyperkey|yabai|WindowServer)" | grep -v grep >> "$ENHANCED_LOG"
        
        # Log current window states after the event
        log_window_states
        
        # Check if this is a cascade (multiple DEMINIMIZED in short time)
        recent_count=$(tail -10 "$LOG_FILE" | grep -c "DEMINIMIZED")
        if [[ $recent_count -gt 1 ]]; then
            echo "🔥 CASCADE DETECTED: $recent_count deminimize events in recent history" >> "$ENHANCED_LOG"
            
            # Log what happened in the last 5 seconds
            echo "=== RECENT LOG CONTEXT ===" >> "$ENHANCED_LOG"
            tail -20 "$LOG_FILE" >> "$ENHANCED_LOG"
            echo "=== END RECENT CONTEXT ===" >> "$ENHANCED_LOG"
        fi
        
        echo "----------------------------------------" >> "$ENHANCED_LOG"
    fi
done &

MONITOR_PID=$!
echo "Enhanced monitoring started with PID: $MONITOR_PID"
echo "Monitor PID: $MONITOR_PID" >> "$ENHANCED_LOG"
echo ""
echo "Monitoring in background. To stop:"
echo "kill $MONITOR_PID"
echo ""
echo "View enhanced log:"
echo "tail -f $ENHANCED_LOG"
echo ""
echo "Reproduce the bug now, then check the enhanced log."