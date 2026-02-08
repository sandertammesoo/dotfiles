#!/usr/bin/zsh

# MINIMAL application-activated handler for testing
# This version does NO window queries to avoid triggering cascades

DEBUG_LOG_FILE="/tmp/yabai_minimize_debug.log"

# Simply log that activation happened without querying windows
echo "[$(date '+%Y-%m-%d %H:%M:%S:%N')] APP_ACTIVATED: MINIMAL - PID $YABAI_PROCESS_ID activated" >> "$DEBUG_LOG_FILE"

# Exit immediately - no window operations
exit 0