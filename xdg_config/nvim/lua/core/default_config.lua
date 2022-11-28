local M = {}
M.options, M.ui, M.mappings, M.plugins = {}, {}, {}, {}

M.ui = {
  -- hl = highlights
  hl_add = {},
  hl_override = {},
  changed_themes = {},
  theme_toggle = { "onedark", "one_light" },
  theme = "onedark", -- default theme
  transparency = false,
}

-- M.plugins = require "custom.plugins"
-- M.plugins = require "custom.plugins.plugins-setup"

M.mappings = require "core.mappings"

return M
