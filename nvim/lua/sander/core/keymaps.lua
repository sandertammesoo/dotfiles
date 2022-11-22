-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- use sf and sa to save files
keymap.set("n", "<leader>wf", ":w<CR>")
keymap.set("n", "<leader>wa", ":wa<CR>")
keymap.set("n", "<leader>qa", ":qa<CR>")
keymap.set("n", "<leader>wqa", ":wqa<CR>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>th", ":20split | term<CR>i")
keymap.set("n", "<leader>tv", ":vsplit | term<CR>i")

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("n", "<leader>et", ":NvimTreeToggle<CR>") -- toggle file explorer
keymap.set("n", "<leader>cx", ":NvimTreeCollapse<CR>") -- collapse file explorer
keymap.set("n", "<leader>cc", ":NvimTreeCollapseKeepBuffers<CR>") -- collapse file explorer
keymap.set("n", "<leader>mn", require("nvim-tree.api").marks.navigate.next)
keymap.set("n", "<leader>mp", require("nvim-tree.api").marks.navigate.prev)
keymap.set("n", "<leader>ms", require("nvim-tree.api").marks.navigate.select)
keymap.set("n", "<leader>ml", require("nvim-tree.api").marks.list)

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fo", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>") -- list recent files
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
keymap.set("n", "<leader>p", "<cmd>Telescope project<CR>") --
-- keymap.set("n", "<leader>p", "<cmd>lua require'telescope'.extensions.project.project{}<CR>") --
keymap.set(
	"n",
	"<leader>fb",
	"<cmd>lua require'telescope'.extensions.file_browser.file_browser{}<CR>"
	-- { noremap = true }
)
keymap.set("n", "<leader>r", "<cmd>Telescope repo cached_list<CR>")
keymap.set("n", "<leader>ed", "<cmd>lua require'sander.edit-dotfiles'.edit_neovim()<CR>")
keymap.set("n", "<leader>cp", "<cmd>Telescope command_palette<cr>") -- list available commands

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- diffview
keymap.set("n", "<leader>dha", "<cmd>DiffviewFileHistory<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>dhf", "<cmd>DiffviewFileHistory %<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>dx", "<cmd>DiffviewClose<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>de", "<cmd>DiffviewToggleFiles<CR>") -- mapping to restart lsp if necessary
keymap.set("n", "<leader>du", "<cmd>DiffviewRefresh<CR>") -- mapping to restart lsp if necessary
