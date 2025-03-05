#!/usr/bin/env zsh
src "$(basename "${(%):-%x}")"

# Ensure Homebrew is installed
if ! command -v /opt/homebrew/bin/brew &>/dev/null; then
  warn " ! Homebrew not installed. Installing now..."
  
  # Install Homebrew based on OS
  case "$(uname -s)" in
    Darwin|Linux)  
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        fail " ✗ Installation failed: Homebrew installation script returned an error."
        exit 1
      }
      ;;
    *)  
      fail " ✗ Installation failed: Unsupported OS ($(uname -s))"
      exit 1
      ;;
  esac
fi

if command -v /opt/homebrew/bin/brew &> /dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
else
  warn " ! Could not find 'brew'. Is Homebrew installed?"
fi
