#!/usr/bin/env zsh

if command -v hopper &> /dev/null; then
    log_success "hopper is installed, setting up shell integration"
    export_n_log HOPPER_CLEAN_GLOSSARY_SKILL=company-knowledge
    export_n_log HOPPER_ME="Sander Tammesoo"
else
    log_skip "hopper not found, skipping hopper shell integration"
fi
