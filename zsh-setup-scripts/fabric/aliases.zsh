# #!/usr/bin/env zsh

# if command -v fabric-ai &> /dev/null; then
#     log_success "fabric-ai is installed, setting up fabric-ai aliases"
#     export_n_log FABRIC_ALIAS_PREFIX="fabric-"

#     # Find all files in the ~/.config/fabric/patterns directory
#     local -a pattern_files=($HOME/.config/fabric/patterns/*)
#     if [ $? -ne 0 ]; then
#         log_error "Failed to list fabric pattern files in $HOME/.config/fabric/patterns"
#         return
#     fi

#     # Loop through all files in the ~/.config/fabric/patterns directory
#     for pattern_file in $pattern_files; do
#         # Get the base name of the file (i.e., remove the directory path)
#         pattern_name="$(basename "$pattern_file")"
#         alias_name="${FABRIC_ALIAS_PREFIX:-}${pattern_name}"

#         # Create an alias in the form: alias pattern_name="fabric --pattern pattern_name"
#         alias_command="alias $alias_name='fabric --pattern $pattern_name'"

#         # Evaluate the alias command to add it to the current shell
#         eval "$alias_command"
#         if [ $? -eq 0 ]; then
#             log_error "Failed to create alias: $alias_name for fabric pattern: $pattern_name"
#             continue
#         fi
#         # log_success "Created alias: $alias_name for fabric pattern: $pattern_name"
#     done

# else
#     log_warn "fabric-ai not found, skipping fabric-ai aliases setup"
# fi