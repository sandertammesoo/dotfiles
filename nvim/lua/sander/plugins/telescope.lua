-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

-- configure telescope
telescope.setup({
	extensions = {
		project = {
			base_dirs = {
				"~/projects",
				--   '~/dev/src',
				--   {'~/dev/src2'},
				--   {'~/dev/src3', max_depth = 4},
				--   {path = '~/dev/src4'},
				--   {path = '~/dev/src5', max_depth = 2},
			},
			hidden_files = true, -- default: false
			theme = "dropdown",
			order_by = "asc",
			sync_with_nvim_tree = true, -- default false
		},
		file_browser = {
			theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			-- hijack_netrw = true,
			--mappings = {
			--	["i"] = {
			--		["<C-k>"] = actions.move_selection_previous, -- move to prev result
			--		["<C-j>"] = actions.move_selection_next, -- move to next result
			--		["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			--	},
			-- 	["n"] = {
			-- 		-- your custom normal mode mappings
			-- 	},
			--},
		},
		repo = {
			list = {
				fd_opts = {
					"--no-ignore-vcs",
				},
				search_dirs = {
					"~/projects",
				},
			},
		},
		command_palette = {
			{
				"Quick",
				{ "Split window vertically", ":vsplit" },
				{ "Split window horisontally", ":split" },
				{ "Make split windows equal", ":wincmd =" },
				{ "Toggle current split maximization", ":MaximizerToggle" },
				{ "Close current split window", ":close" },
				{ "Open terminal below", ":20split | term", 1 },
				{ "Open terminal right", ":vsplit | term", 1 },
				{ "", ":" },
			},
			{
				"Git",
				{ "list all git commits", ":Telescope git_commits" },
				{ "list git commits for current file", ":Telescope git_bcommits" },
				{ "list git branches", ":Telescope git_branches" },
				{ "list current git chances per file with diff preview", ":Telescope git_status" },
				{ "", ":" },
			},
			{
				"Diffview",
				{ "View all git history diffs", ":DiffviewFileHistory" },
				{ "View current file git histroy diffs", ":DiffviewFileHistory %" },
				{ "Open current diff", ":DiffviewOpen" },
				{ "Close current diff", ":DiffviewClose" },
				{ "Toggle File Explorer", ":DiffviewToggleFiles" },
				{ "Update file list", ":DiffviewRefresh" },
			},
			{
				"File",
				{ "toggle project explorer", ":NvimTreeToggle" },
				{ "entire selection (C-a)", ':call feedkeys("GVgg")' },
				{ "save current file (C-s)", ":w" },
				{ "save all files (C-A-s)", ":wa" },
				{ "close file", ":bd" },
				{ "quit (C-q)", ":qa" },
				{ "clear highlighting", ":nohl" },
				{ "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
				{ "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
				{ "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
				{ "files (C-f)", ":lua require('telescope.builtin').find_files()", 1 },
				{ "list recent files", ":Telescope oldfiles" },
				{ "list open files", ":Telescope buffers" },
				{ "list projects", ":Telescope project" },
				{ "list repos", ":Telescope repo cached_list" },
			},
			{
				"Help",
				{ "tips", ":help tips" },
				{ "cheatsheet", ":help index" },
				{ "tutorial", ":help tutor" },
				{ "summary", ":help summary" },
				{ "quick reference", ":help quickref" },
				{ "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
			},
			{
				"Vim",
				{ "reload vimrc", ":source $MYVIMRC" },
				{ "check health", ":checkhealth" },
				{ "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
				{ "commands", ":lua require('telescope.builtin').commands()" },
				{ "command history", ":lua require('telescope.builtin').command_history()" },
				{ "registers (A-e)", ":lua require('telescope.builtin').registers()" },
				{ "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
				{ "vim options", ":lua require('telescope.builtin').vim_options()" },
				{ "keymaps", ":lua require('telescope.builtin').keymaps()" },
				{ "buffers", ":Telescope buffers" },
				{ "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
				{ "paste mode", ":set paste!" },
				{ "cursor line", ":set cursorline!" },
				{ "cursor column", ":set cursorcolumn!" },
				{ "spell checker", ":set spell!" },
				{ "relative number", ":set relativenumber!" },
				{ "search highlighting (F12)", ":set hlsearch!" },
			},
		},
	},

	-- configure custom mappings
	defaults = {
		path_display = function(opts, path)
			local pathLength = string.len(path)
			local maxLength = 41
			local tail = require("telescope.utils").path_tail(path)
			if pathLength > maxLength then
				path = "..." .. string.sub(path, pathLength - maxLength - 3)
			end
			return string.format("(%s)    %s", path, tail)
		end,
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			},
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("project") -- https://github.com/nvim-telescope/telescope-project.nvim
telescope.load_extension("repo") -- https://github.com/cljoly/telescope-repo.nvim
telescope.load_extension("file_browser") -- https://github.com/nvim-telescope/telescope-file-browser.nvim
telescope.load_extension("command_palette") -- https://github.com/LinArcX/telescope-command-palette.nvim

-- -- https://github.com/NvChad/NvChad
-- vim.g.theme_switcher_loaded = true
--
-- require("base46").load_highlight("telescope")
--
-- local options = {
-- 	defaults = {
-- 		path_display = function(opts, path)
-- 			local pathLength = string.len(path)
-- 			local maxLength = 41
-- 			local tail = require("telescope.utils").path_tail(path)
-- 			if pathLength > maxLength then
-- 				path = "..." .. string.sub(path, pathLength - maxLength - 3)
-- 			end
-- 			return string.format("(%s)    %s", path, tail)
-- 		end,
-- 		mappings = { -- configure custom mappings
-- 			i = {
-- 				["<C-k>"] = actions.move_selection_previous, -- move to prev result
-- 				["<C-j>"] = actions.move_selection_next, -- move to next result
-- 				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
-- 			},
-- 		},
-- 	},
--
-- 	extensions = {
-- 		project = {
-- 			base_dirs = {
-- 				"~/projects",
-- 				--   '~/dev/src',
-- 				--   {'~/dev/src2'},
-- 				--   {'~/dev/src3', max_depth = 4},
-- 				--   {path = '~/dev/src4'},
-- 				--   {path = '~/dev/src5', max_depth = 2},
-- 			},
-- 			hidden_files = true, -- default: false
-- 			theme = "dropdown",
-- 			order_by = "asc",
-- 			sync_with_nvim_tree = true, -- default false
-- 		},
-- 		file_browser = {
-- 			theme = "ivy",
-- 			-- disables netrw and use telescope-file-browser in its place
-- 			-- hijack_netrw = true,
-- 			--mappings = {
-- 			--	["i"] = {
-- 			--		["<C-k>"] = actions.move_selection_previous, -- move to prev result
-- 			--		["<C-j>"] = actions.move_selection_next, -- move to next result
-- 			--		["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
-- 			--	},
-- 			-- 	["n"] = {
-- 			-- 		-- your custom normal mode mappings
-- 			-- 	},
-- 			--},
-- 		},
-- 		repo = {
-- 			list = {
-- 				fd_opts = {
-- 					"--no-ignore-vcs",
-- 				},
-- 				search_dirs = {
-- 					"~/projects",
-- 				},
-- 			},
-- 		},
-- 		command_palette = {
-- 			{
-- 				"Quick",
-- 				{ "Split window vertically", ":vsplit" },
-- 				{ "Split window horisontally", ":split" },
-- 				{ "Make split windows equal", ":wincmd =" },
-- 				{ "Toggle current split maximization", ":MaximizerToggle" },
-- 				{ "Close current split window", ":close" },
-- 				{ "Open terminal below", ":20split | term", 1 },
-- 				{ "Open terminal right", ":vsplit | term", 1 },
-- 				{ "", ":" },
-- 			},
-- 			{
-- 				"Git",
-- 				{ "list all git commits", ":Telescope git_commits" },
-- 				{ "list git commits for current file", ":Telescope git_bcommits" },
-- 				{ "list git branches", ":Telescope git_branches" },
-- 				{ "list current git chances per file with diff preview", ":Telescope git_status" },
-- 				{ "", ":" },
-- 			},
-- 			{
-- 				"File",
-- 				{ "toggle project explorer", ":NvimTreeToggle" },
-- 				{ "entire selection (C-a)", ':call feedkeys("GVgg")' },
-- 				{ "save current file (C-s)", ":w" },
-- 				{ "save all files (C-A-s)", ":wa" },
-- 				{ "close file", ":bd" },
-- 				{ "quit (C-q)", ":qa" },
-- 				{ "clear highlighting", ":nohl" },
-- 				{ "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
-- 				{ "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
-- 				{ "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
-- 				{ "files (C-f)", ":lua require('telescope.builtin').find_files()", 1 },
-- 				{ "list recent files", ":Telescope oldfiles" },
-- 				{ "list open files", ":Telescope buffers" },
-- 				{ "list projects", ":Telescope project" },
-- 				{ "list repos", ":Telescope repo cached_list" },
-- 			},
-- 			{
-- 				"Help",
-- 				{ "tips", ":help tips" },
-- 				{ "cheatsheet", ":help index" },
-- 				{ "tutorial", ":help tutor" },
-- 				{ "summary", ":help summary" },
-- 				{ "quick reference", ":help quickref" },
-- 				{ "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
-- 			},
-- 			{
-- 				"Vim",
-- 				{ "reload vimrc", ":source $MYVIMRC" },
-- 				{ "check health", ":checkhealth" },
-- 				{ "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
-- 				{ "commands", ":lua require('telescope.builtin').commands()" },
-- 				{ "command history", ":lua require('telescope.builtin').command_history()" },
-- 				{ "registers (A-e)", ":lua require('telescope.builtin').registers()" },
-- 				{ "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
-- 				{ "vim options", ":lua require('telescope.builtin').vim_options()" },
-- 				{ "keymaps", ":lua require('telescope.builtin').keymaps()" },
-- 				{ "buffers", ":Telescope buffers" },
-- 				{ "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
-- 				{ "paste mode", ":set paste!" },
-- 				{ "cursor line", ":set cursorline!" },
-- 				{ "cursor column", ":set cursorcolumn!" },
-- 				{ "spell checker", ":set spell!" },
-- 				{ "relative number", ":set relativenumber!" },
-- 				{ "search highlighting (F12)", ":set hlsearch!" },
-- 			},
-- 		},
-- 	},
--
-- 	extensions_list = { "themes", "fzf", "project", "repo", "file_browser", "command_palette" },
-- }
--
-- -- check for any override
-- options = require("core.utils").load_override(options, "nvim-telescope/telescope.nvim")
-- telescope.setup(options)
--
-- -- load extensions
-- pcall(function()
-- 	for _, ext in ipairs(options.extensions_list) do
-- 		telescope.load_extension(ext)
-- 	end
-- end)
