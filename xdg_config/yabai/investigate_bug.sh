#!/usr/bin/env zsh

# Test script to help investigate minimize bug triggers

echo "🔍 Minimize Bug Investigation Helper"
echo "===================================="
echo ""

# 1. Check current system state
echo "1. Current minimized windows:"
yabai -m query --windows | jq -r '.[] | select(.["is-minimized"] == true) | "  \(.app): window \(.id) on space \(.space)"'

if [[ $(yabai -m query --windows | jq '[.[] | select(.["is-minimized"] == true)] | length') -eq 0 ]]; then
    echo "  No windows are currently minimized."
    echo ""
    echo "🔧 To test the bug:"
    echo "  1. Minimize 2-3 windows from different apps"
    echo "  2. Click dock or use Cmd+Tab to focus a minimized window"
    echo "  3. Watch if all minimized windows deminimize"
    echo ""
fi

echo ""
echo "2. Potentially interfering processes:"
echo "  Hyperkey: $(pgrep -f Hyperkey > /dev/null && echo "✅ Running" || echo "❌ Not running")"
echo "  WindowServer: $(pgrep WindowServer > /dev/null && echo "✅ Running" || echo "❌ Not running")"
echo "  osascript processes: $(pgrep osascript | wc -l | tr -d ' ') running"

echo ""
echo "3. Relevant system settings:"
echo "  Dock minimize-to-application: $(defaults read com.apple.dock minimize-to-application 2>/dev/null || echo "default")"
echo "  Window grouping: $(defaults read com.apple.WindowManager AppWindowGroupingBehavior 2>/dev/null || echo "default")"

echo ""
echo "4. Enhanced monitoring status:"
if pgrep -f "enhanced_debug.sh" > /dev/null; then
    echo "  ✅ Enhanced monitoring is running"
    echo "  View log: tail -f /tmp/yabai_enhanced_debug.log"
else
    echo "  ❌ Enhanced monitoring not running"
    echo "  Start it: ~/.config/yabai/enhanced_debug.sh"
fi

echo ""
echo "5. Debug log status:"
if [[ -f /tmp/yabai_minimize_debug.log ]]; then
    echo "  Log size: $(wc -l < /tmp/yabai_minimize_debug.log) lines"
    echo "  Recent DEMINIMIZED events: $(tail -100 /tmp/yabai_minimize_debug.log | grep -c "DEMINIMIZED")"
else
    echo "  ❌ No debug log found"
fi

echo ""
echo "6. Quick test commands:"
echo "  View real-time debug: ~/.config/yabai/debug_minimize.sh tail"
echo "  View enhanced log: tail -f /tmp/yabai_enhanced_debug.log"
echo "  Stop enhanced monitoring: kill \$(pgrep -f enhanced_debug.sh)"

# 7. Hypothesis tests
echo ""
echo "7. Hypothesis Testing:"
echo "  Test A - Hyperkey interference:"
echo "    killall Hyperkey; reproduce bug; restart Hyperkey"
echo ""
echo "  Test B - Dock setting interference:"
echo "    defaults write com.apple.dock minimize-to-application -bool false"
echo "    killall Dock; reproduce bug"
echo ""
echo "  Test C - macOS Window grouping:"
echo "    defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 0"
echo "    killall WindowManager; reproduce bug"