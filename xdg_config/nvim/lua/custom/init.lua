-- Setup globals that I expect to be always available.
--  See `./lua/tj/globals.lua` for more information.
require "custom.globals"

-- if require "custom.first_load"() then
--   return
-- end

local opt = vim.opt
local g = vim.g

-- Leader key -> ","
--
-- In general, it's a good idea to set this early in your config, because otherwise
-- if you have any mappings you set BEFORE doing this, they will be set to the OLD
-- leader.
g.mapleader = " "
g.maplocalleader = " "

-- I set some global variables to use as configuration throughout my config.
-- These don't have any special meaning.
g.snippets = "luasnip"

-- backspace
opt.backspace = "indent,eol,start"
opt.iskeyword:append "-"
opt.mousescroll = "ver:1,hor:1"

-- Cool floating window popup menu for completion on command line
opt.pumblend = 17
opt.wildmode = "longest:full"
opt.wildoptions = "pum"

opt.showmode = false
opt.showcmd = true
opt.cmdheight = 1 -- Height of the command bar
opt.incsearch = true -- Makes search act like search in modern browsers
opt.showmatch = true -- show matching brackets when text indicator is over them
opt.relativenumber = true -- Show line numbers
opt.number = true -- But show the actual number for the line we're on
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ... unless there is a capital letter in the query
opt.hidden = true -- I like having buffers stay around
opt.equalalways = false -- I don't like my windows changing all the time
opt.splitright = true -- Prefer windows splitting to the right
opt.splitbelow = true -- Prefer windows splitting to the bottom
opt.updatetime = 1000 -- Make updates happen faster
-- opt.hlsearch = true -- I wouldn't use this without my DoNoHL function
opt.scrolloff = 10 -- Make it so there are always ten lines below my cursor

-- Tabs
opt.autoindent = true
opt.cindent = true
opt.wrap = true
-- opt.wrap = false

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

opt.breakindent = true
opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
opt.linebreak = true

opt.foldmethod = "marker"
opt.foldlevel = 0
opt.modelines = 1

-- opt.belloff = "all" -- Just turn the dang bell off

opt.clipboard = "unnamedplus"

opt.inccommand = "split"
-- opt.swapfile = false -- Living on the edge
opt.shada = { "!", "'1000", "<50", "s10", "h" }

opt.mouse = "a"

-- Helpful related items:
--   1. :center, :left, :right
--   2. gw{motion} - Put cursor back after formatting motion.
--
-- TODO: w, {v, b, l}
opt.formatoptions = opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

-- set joinspaces
-- opt.joinspaces = false -- Two spaces and grade school, we're done

-- set fillchars=eob:~
-- opt.fillchars = { eob = "~" }

vim.opt.diffopt = { "internal", "filler", "closeoff", "hiddenoff", "algorithm:minimal" }

vim.opt.undofile = true
vim.opt.signcolumn = "yes"

-- Turn off builtin plugins I do not use.
require "custom.disable_builtin"

-- -- Force loading of astronauta first.
-- vim.cmd [[runtime plugin/astronauta.vim]]

-- TODO: Study TJ's LSP init.lua and think what and how to use
-- /Users/sander/Library/CloudStorage/GoogleDrive-sander.tammesoo@gmail.com/My Drive/9 - Arhiiv/910 - Personal/919. Self dev/919.2. SW Projects/config_manager/xdg_config/nvim/lua/tj/lsp/init.lua
-- -- Neovim builtin LSP configuration
-- require "tj.lsp"

-- -- autocommand that reloads neovim and installs/updates/removes plugins
-- -- when file is saved
-- vim.cmd [[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
--   augroup end
-- ]]
