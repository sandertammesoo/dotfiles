# Zsh Dotfiles Load Order

Zsh follows a specific order when loading configuration files. These files control the behavior of the shell, environment variables, and startup commands.

## Load Order

1. **`/etc/zshenv`** – A system-wide configuration file that is sourced for every Zsh shell, regardless of whether it is interactive or a login shell.
2. **`$ZDOTDIR/.zshenv`** – A user-specific configuration file that is sourced for every Zsh shell, used for environment variables and minimal setup.
3. **`/etc/zprofile`** – A system-wide file sourced only by login shells before running the user's `.zprofile`, typically used for setting up environment variables.
4. **`$ZDOTDIR/.zprofile`** – A user-specific file sourced only by login shells, often used for exporting environment variables and running startup commands.
5. **`/etc/zshrc`** – A system-wide configuration file sourced by interactive shells, usually containing shared shell settings and aliases.
6. **`$ZDOTDIR/.zshrc`** – A user-specific configuration file sourced by interactive shells, commonly used for shell customization like aliases and prompt settings.
7. **`/etc/zlogin`** – A system-wide file sourced by login shells after `.zprofile`, often used for displaying messages or running final setup commands.
8. **`$ZDOTDIR/.zlogin`** – A user-specific file sourced by login shells after `.zprofile`, typically used for commands that should run only at login, like starting a session manager.

## Notes

- **Login shells** load `.zprofile` and `.zlogin`, but **non-login interactive shells** only load `.zshrc`.
- **Non-interactive shells** (e.g., scripts) typically only load `.zshenv`.
- **`ZDOTDIR`** defaults to the user's home directory (`$HOME`), meaning dotfiles are usually found in `~/.zshenv`, `~/.zshrc`, etc.
