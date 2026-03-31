#!/bin/bash
# Maps a Brave Browser window title to an appropriate app icon.
# Falls back to :brave_browser: for unrecognized pages.
# Usage: brave_page_icon.sh "<window_title>"

title="$1"
case "$title" in
  *"YouTube"*)  echo ":youtube:" ;;
  *"Netflix"*)  echo ":netflix:" ;;
  *"GitHub"*)   echo ":git_hub:" ;;
  *)            echo ":brave_browser:" ;;
esac
