-- import nvim-tree plugin safely
local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
	return
end

local lib_setup, lib = pcall(require, "nvim-tree.lib")
if not lib_setup then
	return
end

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

local function cd_dot_cb(node)
	nvimtree.change_dir(vim.fn.getcwd(-1))
	if node.name ~= ".." then
		lib.set_index_and_redraw(node.absolute_path)
	end
end

-- configure nvim-tree
nvimtree.setup({
	view = {
		preserve_window_proportions = true,
		mappings = {
			list = {
				-- { key = {"<2-RightMouse>", "<C-]>"},    action = "" }, -- cd
				-- { key = "<C-v>",                        action = "" }, -- vsplit
				-- { key = "<C-x>",                        action = "" }, -- split
				-- { key = "<C-t>",                        action = "" }, -- tabnew
				-- { key = "<BS>",                         action = "" }, -- close_node
				-- { key = "<Tab>",                        action = "" }, -- preview
				-- { key = "D",                            action = "" }, -- trash
				-- { key = "[c",                           action = "" }, -- prev_git_item
				-- { key = "]c",                           action = "" }, -- next_git_item
				-- { key = "-",                            action = "" }, -- dir_up
				-- { key = "s",                            action = "" }, -- system_open
				--
				-- { key = "d",                            action = "cd" }, -- remove
				-- { key = "x",                            action = "remove" }, -- cut
				--
				-- { key = "t",                            action = "cut" },
				-- { key = "<Space>k",                     action = "prev_git_item" },
				-- { key = "<Space>j",                     action = "next_git_item" },
				-- { key = "u",                            action = "dir_up" },
				-- { key = "f",                            action = "run_file_command" },
				-- { key = "z",                            action = "close_node" },
				--
				{ key = ".", action = "cd_dot", action_cb = cd_dot_cb }, -- run_file_command
			},
		},
	},
	-- change folder arrow icons
	renderer = {
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "", -- arrow when folder is closed
					arrow_open = "", -- arrow when folder is open
				},
			},
		},
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	-- 	git = {
	-- 		ignore = false,
	-- 	},
})
