#!/bin/bash
# Maps a Brave Browser window title to an appropriate app icon.
# Falls back to :brave_browser: for unrecognized pages.
# Usage: brave_page_icon.sh "<window_title>"

title="$1"

# GitHub: explicit word OR repo-style title patterns:
#   - Suffix style: "owner/repo: description", "owner/repo Wiki", "owner/repo · Discussions"
#   - Prefix style: "Issues · owner/repo", "Pull Requests · owner/repo"
_github_suffix='[^/[:space:]]+/[^[:space:]]+( -|: | Wiki| · Discussions)'
_github_prefix='(Issues|Pull Requests|Commits|Tags|Actions|Releases) · [^/[:space:]]+/[^[:space:]]+'

if [[ "$title" == *"YouTube"* ]]; then
  echo ":youtube:"
elif [[ "$title" == *"Netflix"* ]]; then
  echo ":netflix:"
elif [[ "$title" == *"GitHub"* ]] || [[ "$title" =~ $_github_suffix ]] || [[ "$title" =~ $_github_prefix ]]; then
  echo ":git_hub:"
elif [[ "$title" == *"Figma"* ]]; then
  echo ":figma:"
else
  echo ":brave_browser:"
fi
