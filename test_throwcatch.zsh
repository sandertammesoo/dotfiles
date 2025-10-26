#!/usr/bin/env zsh

source helpers_logging.zsh
autoload -Uz throw catch

local file="$1" level="${2:-WARN}"

 {
    # "try" block
    [[ -f "$file" ]] || throw MyExceptFileNotFound
    source "$file" || throw MyExceptFailedToSource
    _log VERB "Sourced $file"
  } always {
    # "always" block
    # code

    # "catch" block
    if catch *; then
      case $CAUGHT in
        (MyExceptFileNotFound)
            echo "Caught my own exception: $CAUGHT"
            _log "${level:u}" "Caught my own exception: $CAUGHT"
            ;;
        (MyExceptFailedToSource)
            echo "Caught my own exception: $CAUGHT"
            _log "${level:u}" "Caught my own exception: $CAUGHT"
            ;;
        (*)
            echo "Caught some other exception: $CAUGHT"
            _log "${level:u}" "Caught some other exception: $CAUGHT"
            ;;
      esac
    fi

    # "finally" block
    # code
  }