-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope project safely
--local project_setup, project = pcall(require, "telescope.project")
--if not project_setup then
--	return
--end

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
	},
	-- configure custom mappings
	defaults = {
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
