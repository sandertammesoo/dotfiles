-- Attempt to run impatient, but it may not have been installed yet
vim.defer_fn(function()
  pcall(require, "impatient")
end, 0)

-- require "custom.profile"

-- Setup globals that I expect to be always available.
--  See `./lua/custom/globals.lua` for more information.
require "custom.globals"
require "core.options"

-- setup packer + plugins{{{
-- if require "custom.first_load"() then{{{
--   return
-- end
-- }}}
local fn = vim.fn
local install_path = fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e222a" })
  print "Cloning packer .."
  fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }

  -- install plugins + compile their configs
  vim.cmd "packadd packer.nvim"
  require "plugins"
  vim.cmd "PackerSync"

  -- install binaries from mason.nvim & tsparsers
  vim.api.nvim_create_autocmd("User", {
    pattern = "PackerComplete",
    callback = function()
      vim.cmd "bw | silent! MasonInstallAll" -- close packer window
      require("packer").loader "nvim-treesitter"
    end,
  })
end -- }}}

-- Turn off builtin plugins I do not use.
require "custom.disable_builtin"

-- -- Force loading of astronauta first.
-- vim.cmd [[runtime plugin/astronauta.vim]]

-- TODO: Study TJ's LSP init.lua and think what and how to use{{{{{{
-- /Users/sander/Library/CloudStorage/GoogleDrive-sander.tammesoo@gmail.com/My Drive/9 - Arhiiv/910 - Personal/919. Self dev/919.2. SW Projects/config_manager/xdg_config/nvim/lua/tj/lsp/init.lua -- }}}
-- Neovim builtin LSP configuration}}}
-- require "custom.lsp"

-- Telescope BTW
-- require "custom.telescope.setup"
-- require "custom.telescope.mappings"
require("core.utils").load_mappings() -- loads mappings using load_config which reads from default_config and chadrc and merges them

-- -- autocommand that reloads neovim and installs/updates/removes plugins{{{
-- -- when file is saved
-- vim.cmd [[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
--   augroup end
-- ]]}}}
