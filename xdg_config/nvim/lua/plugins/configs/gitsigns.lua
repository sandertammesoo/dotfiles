local load_override = R("core.utils").load_override
local utils = R "core.utils"

local present, gitsigns = pcall(require, "gitsigns")

if not present then
  return
end

require("base46").load_highlight "git"

local options = {
  signs = {
    add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
    change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
    delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
    topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
    changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
  },
  on_attach = function(bufnr)
    utils.load_mappings("gitsigns", { buffer = bufnr })
  end,
}

options = load_override(options, "lewis6991/gitsigns.nvim")
gitsigns.setup(options)
