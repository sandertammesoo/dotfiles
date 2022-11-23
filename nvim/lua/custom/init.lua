local opt = vim.opt
-- local g = vim.g

-- opt.clipboard:append("unnamedplus")
opt.wrap = false
opt.autoindent = true
opt.relativenumber = true
-- opt.background = "dark"
-- opt.timeoutlen = 0

-- backspace
opt.backspace = "indent,eol,start"
opt.iskeyword:append "-"
opt.mousescroll = "ver:1,hor:1"


-- -- autocommand that reloads neovim and installs/updates/removes plugins
-- -- when file is saved
-- vim.cmd([[ 
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost init.lua source <afile> | PackerSync
--   augroup end
-- ]])
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])
