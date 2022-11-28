local present, telescope = pcall(require, "telescope")

if not present then
  return
end

vim.g.theme_switcher_loaded = true

require("base46").load_highlight "telescope"

local options = {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
      i = {
        ["<C-k>"] = require("telescope.actions").move_selection_previous, -- move to prev result
        ["<C-j>"] = require("telescope.actions").move_selection_next, -- move to next result
        ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist, -- send selected to quickfixlist
      },
    },
  },

  -- extensions = {
  -- 	project = {
  -- 		base_dirs = { "~/projects" },
  -- 		hidden_files = true, -- default: false
  -- 		theme = "dropdown",
  -- 		order_by = "asc",
  -- 		sync_with_nvim_tree = true, -- default false
  -- 	},
  -- 	file_browser = {
  -- 		theme = "ivy",
  -- 		-- disables netrw and use telescope-file-browser in its place
  -- 		-- hijack_netrw = true,
  -- 		--mappings = {
  -- 		--	["i"] = {
  -- 		--		["<C-k>"] = actions.move_selection_previous, -- move to prev result
  -- 		--		["<C-j>"] = actions.move_selection_next, -- move to next result
  -- 		--		["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
  -- 		--	},
  -- 		-- 	["n"] = {
  -- 		-- 		-- your custom normal mode mappings
  -- 		-- 	},
  -- 		--},
  -- 	},
  -- 	repo = {
  -- 		list = {
  -- 			fd_opts = {
  -- 				"--no-ignore-vcs",
  -- 			},
  -- 			search_dirs = {
  -- 				"~/projects",
  -- 			},
  -- 		},
  -- 	},
  -- 	command_palette = {
  -- 		{
  -- 			"Quick",
  -- 			{ "Split window vertically", ":vsplit" },
  -- 			{ "Split window horisontally", ":split" },
  -- 			{ "Make split windows equal", ":wincmd =" },
  -- 			{ "Toggle current split maximization", ":MaximizerToggle" },
  -- 			{ "Close current split window", ":close" },
  -- 			{ "Open terminal below", ":20split | term", 1 },
  -- 			{ "Open terminal right", ":vsplit | term", 1 },
  -- 			{ "", ":" },
  -- 		},
  -- 		{
  -- 			"Git",
  -- 			{ "list all git commits", ":Telescope git_commits" },
  -- 			{ "list git commits for current file", ":Telescope git_bcommits" },
  -- 			{ "list git branches", ":Telescope git_branches" },
  -- 			{ "list current git chances per file with diff preview", ":Telescope git_status" },
  -- 			{ "", ":" },
  -- 		},
  -- 		{
  -- 			"Diffview",
  -- 			{ "View all git history diffs", ":DiffviewFileHistory" },
  -- 			{ "View current file git histroy diffs", ":DiffviewFileHistory %" },
  -- 			{ "Open current diff", ":DiffviewOpen" },
  -- 			{ "Close current diff", ":DiffviewClose" },
  -- 			{ "Toggle File Explorer", ":DiffviewToggleFiles" },
  -- 			{ "Update file list", ":DiffviewRefresh" },
  -- 		},
  -- 		{
  -- 			"File",
  -- 			{ "toggle project explorer", ":NvimTreeToggle" },
  -- 			{ "entire selection (C-a)", ':call feedkeys("GVgg")' },
  -- 			{ "save current file (C-s)", ":w" },
  -- 			{ "save all files (C-A-s)", ":wa" },
  -- 			{ "close file", ":bd" },
  -- 			{ "quit (C-q)", ":qa" },
  -- 			{ "clear highlighting", ":nohl" },
  -- 			{ "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
  -- 			{ "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
  -- 			{ "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
  -- 			{ "files (C-f)", ":lua require('telescope.builtin').find_files()", 1 },
  -- 			{ "list recent files", ":Telescope oldfiles" },
  -- 			{ "list open files", ":Telescope buffers" },
  -- 			{ "list projects", ":Telescope project" },
  -- 			{ "list repos", ":Telescope repo cached_list" },
  -- 		},
  -- 		{
  -- 			"Help",
  -- 			{ "tips", ":help tips" },
  -- 			{ "cheatsheet", ":help index" },
  -- 			{ "tutorial", ":help tutor" },
  -- 			{ "summary", ":help summary" },
  -- 			{ "quick reference", ":help quickref" },
  -- 			{ "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
  -- 		},
  -- 		{
  -- 			"Vim",
  -- 			{ "reload vimrc", ":source $MYVIMRC" },
  -- 			{ "check health", ":checkhealth" },
  -- 			{ "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
  -- 			{ "commands", ":lua require('telescope.builtin').commands()" },
  -- 			{ "command history", ":lua require('telescope.builtin').command_history()" },
  -- 			{ "registers (A-e)", ":lua require('telescope.builtin').registers()" },
  -- 			{ "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
  -- 			{ "vim options", ":lua require('telescope.builtin').vim_options()" },
  -- 			{ "keymaps", ":lua require('telescope.builtin').keymaps()" },
  -- 			{ "buffers", ":Telescope buffers" },
  -- 			{ "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
  -- 			{ "paste mode", ":set paste!" },
  -- 			{ "cursor line", ":set cursorline!" },
  -- 			{ "cursor column", ":set cursorcolumn!" },
  -- 			{ "spell checker", ":set spell!" },
  -- 			{ "relative number", ":set relativenumber!" },
  -- 			{ "search highlighting (F12)", ":set hlsearch!" },
  -- 		},
  -- 	},
  -- },
  --
  --  extensions_list = { "themes", "terms", "project", "repo", "command_palette", "file_browser", "fzf" },
  --  }
  extensions_list = { "themes", "terms" },
}

-- check for any override
options = require("core.utils").load_override(options, "nvim-telescope/telescope.nvim")
telescope.setup(options)

-- load extensions
pcall(function()
  for _, ext in ipairs(options.extensions_list) do
    telescope.load_extension(ext)
  end
end)
