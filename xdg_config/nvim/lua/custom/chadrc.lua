-- First read our docs (completely) then check the example_config repo

local M = {}
-- M.options, M.ui, M.mappings, M.plugins = {}, {}, {}, {}

M.ui = {
  theme = "onedark",
}

-- M.plugins = require "custom.plugins"
M.plugins = require "custom.plugins.plugins-setup"
M.mappings = require "custom.mappings"

return M
