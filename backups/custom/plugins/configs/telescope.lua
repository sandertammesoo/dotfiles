local present, telescope = pcall(require, "telescope")

if not present then
  return
end

local options = {
  defaults = {
    mappings = {
			i = {
				["<C-k>"] = require("telescope.actions").move_selection_previous, -- move to prev result
				["<C-j>"] = require("telescope.actions").move_selection_next, -- move to next result
				["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist, -- send selected to quickfixlist
			},
    },
	extensions = {
		project = {
			base_dirs = { "~/projects" },
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

  extensions_list = { "themes", "terms", "project", "repo", "command_palette", "file_browser", "fzf" },
  }
}

-- load extensions
pcall(function()
  for _, ext in ipairs(options.extensions_list) do
    print(ext)
    telescope.load_extension(ext)
  end
end)


