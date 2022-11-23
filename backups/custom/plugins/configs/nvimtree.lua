local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

local function cd_dot_cb(node)
	nvimtree.change_dir(vim.fn.getcwd(-1))
	if node.name ~= ".." then
		require("nvim-tree.lib").set_index_and_redraw(node.absolute_path)
	end
end

local options = {
  view = {
		-- preserve_window_proportions = true,
    mappings = {
			{ key = ".", action = "cd_dot", action_cb = cd_dot_cb }, -- run_file_command
    }
  },
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    highlight_opened_files = "none",

    icons = {
      show = {
        git = true,
      },
    },
  },

}
