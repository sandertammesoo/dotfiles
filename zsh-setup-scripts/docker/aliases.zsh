#!/bin/zsh
src "$(basename "${(%):-%x}")"
alias d='docker $*'
alias d-c='docker-compose $*'
