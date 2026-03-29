-- wezterm.lua
-- WezTerm as a pure viewport for tmux. No built-in mux, no tabs, no panes.

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ── Appearance ────────────────────────────────────────────────────────────────
 
-- Change the font and the font size.
config.line_height = 1.2
config.font_size = 18
config.font = wezterm.font("MesloLGS Nerd Font Mono", {weight="Regular"})
config.font = wezterm.font_with_fallback {
  "MesloLGS Nerd Font Mono",
  "Symbols Nerd Font Mono", -- for icons
  "Noto Sans Symbols 2",      -- for emojis
}

-- Good dark theme that doesn't fight with tmux's status bar
config.color_scheme = 'Tokyo Night (Gogh)'
config.colors = {
    cursor_bg = "#7aa2f7",
    cursor_border = "#7aa2f7",
}
-- -- Set theme to Catppuccin Mocha
-- config.color_scheme = 'Catppuccin Mocha' -- Other flavours: latte, frappe, macchiato, mocha
-- config.colors = { -- Set cursor color to match theme's accent color
--     cursor_bg = "#f5e0dc",
--     cursor_border = "#f5e0dc",
-- }

-- Let tmux own all visual chrome — hide WezTerm's tab bar entirely
config.enable_tab_bar = false

-- Native macOS borderless look
config.window_decorations = "RESIZE"
config.window_padding = {
  left   = 4,
  right  = 4,
  top    = 4,
  bottom = 4,
}

-- Subtle transparency
config.window_background_opacity = 0.90
config.macos_window_background_blur = 8


-- ── Terminal capabilities ─────────────────────────────────────────────────────
 
-- Critical: tell tmux and apps that we support true color
config.term = 'xterm-256color'
 
-- Allow applications (tmux, vim, etc.) to set the window title
config.set_environment_variables = {
  TERM_PROGRAM = 'WezTerm',
}
 
 
-- ── Behaviour ─────────────────────────────────────────────────────────────────
 
-- Confirm before closing only if a process is running
config.window_close_confirmation = 'NeverPrompt' -- 'AlwaysPrompt'
 
-- Don't auto-reload config mid-session (prevents flicker)
config.automatically_reload_config = true -- false
 
-- scrollback is mostly irrelevant when using tmux, but set a sane value
config.scrollback_lines = 5000


-- ── Keys ──────────────────────────────────────────────────────────────────────
 
-- Pass everything through to tmux. Disable WezTerm's own keybindings
-- that would conflict with tmux prefix (Ctrl-b) or vim (Ctrl-a, etc.)
config.disable_default_key_bindings = false
 
-- The one WezTerm shortcut worth keeping: paste from clipboard
-- (tmux can't intercept this from outside the terminal)
config.keys = {
  {
    key  = 'v',
    mods = 'CMD',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  {
    key  = 'c',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  -- Cmd+Left/Right → beginning/end of line (sends Home/End sequences to ZSH)
  {
    key  = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x1b[H',
  },
  {
    key  = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x1b[F',
  },
  -- Quick font size adjustments without touching tmux
  {
    key  = '=',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key  = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key  = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },
  -- ── Warp-style splits ────────────────────────────────────────────────────
  -- CMD+D        → split vertically (side by side, like Warp)
  -- CMD+Shift+D  → split horizontally (top/bottom, like Warp)
  {
    key = "w", 
    mods = "CMD", 
    action = wezterm.action{CloseCurrentPane={confirm=false}}
  },
  {
    key = "d", 
    mods = "CMD", 
    action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}
  },
  {
    key = "d", 
    mods = "CMD|SHIFT", 
    action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}
  },
  -- -- Sent directly as tmux commands — no prefix needed.
  -- {
  --   key  = 'd',
  --   mods = 'CMD',
  --   action = wezterm.action.SendString '\x02%',  -- Ctrl-b then %
  -- },
  -- {
  --   key  = 'd',
  --   mods = 'CMD|SHIFT',
  --   action = wezterm.action.SendString '\x02"',  -- Ctrl-b then "
  -- },
}


-- ── Mouse ─────────────────────────────────────────────────────────────────────
 
-- Right-click pastes (common terminal convention)
config.mouse_bindings = {
  {
    event  = { Down = { streak = 1, button = 'Right' } },
    mods   = 'NONE',
    action = wezterm.action.PasteFrom 'PrimarySelection',
  },
}

-- Finally, return the configuration to wezterm:
return config