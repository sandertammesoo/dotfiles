local opt = vim.opt
local g = vim.g

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- opt.clipboard:append("unnamedplus")
opt.wrap = false
opt.autoindent = true
opt.relativenumber = true
-- opt.background = "dark"
-- opt.timeoutlen = 0 -- Not currently working with which-key :/

-- backspace
opt.backspace = "indent,eol,start"
opt.iskeyword:append "-"
opt.mousescroll = "ver:1,hor:1"

-- -- autocommand that reloads neovim and installs/updates/removes plugins
-- -- when file is saved
-- vim.cmd [[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
--   augroup end
-- ]]
