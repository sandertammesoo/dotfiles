local opt = vim.opt
local g = vim.g

-- if vim.g.neovide then
--   vim.g.neovide_cursor_trail_legnth = 0
--   vim.g.neovide_cursor_animation_length = 0
--   vim.o.guifont = "Jetbrains Mono"
-- end

-- Theme selection options
g.nvchad_theme = "onedark"
g.toggle_theme_icon = "   "
g.transparency = false
g.theme_switcher_loaded = false

opt.laststatus = 3 -- Enable global statusline
opt.showmode = false -- ??
opt.showcmd = true
opt.cmdheight = 1 -- Height of the command bar
opt.incsearch = true -- Makes search act like search in modern browsers
opt.inccommand = "split"
-- opt.swapfile = false -- Living on the edge
opt.shada = { "!", "'1000", "<50", "s10", "h" }
opt.showmatch = true -- show matching brackets when text indicator is over them

opt.clipboard = "unnamedplus" -- Enable system clipboard
opt.cursorline = true -- Highlight cursorline

-- Indenting
opt.autoindent = true
opt.cindent = true
opt.wrap = true
-- opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2
opt.breakindent = true
opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
opt.linebreak = true
opt.foldmethod = "marker"
opt.foldlevel = 0
opt.modelines = 1

opt.fillchars = { eob = " " }
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ... unless there is a capital letter in the query
opt.mouse = "a"

-- Numbers
opt.relativenumber = true -- Show line numbers
opt.number = true -- But show the actual number for the line we're on
opt.numberwidth = 2
opt.ruler = false

-- disable nvim intro
opt.shortmess:append "sI"

opt.signcolumn = "yes"
opt.hidden = true -- I like having buffers stay around
opt.equalalways = false -- I don't like my windows changing all the time
opt.splitright = true -- Prefer windows splitting to the right
opt.splitbelow = true -- Prefer windows splitting to the bottom
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true
-- opt.hlsearch = true -- I wouldn't use this without my DoNoHL function
opt.scrolloff = 10 -- Make it so there are always ten lines below my cursor

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- In general, it's a good idea to set this early in your config, because otherwise if you have any mappings you set BEFORE doing this, they will be set to the OLD leader.
g.mapleader = " "
g.maplocalleader = " "
g.mapleader = " "

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
-- opt.wildoptions = "pum"

-- Helpful related items:
--   1. :center, :left, :right
--   2. gw{motion} - Put cursor back after formatting motion.
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

opt.diffopt = { "internal", "filler", "closeoff", "hiddenoff", "algorithm:minimal" }

-- disable some builtin vim plugins
local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(default_plugins) do
  g["loaded_" .. plugin] = 1
end

local default_providers = {
  "node",
  "perl",
  "python3",
  "ruby",
}

for _, provider in ipairs(default_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end
