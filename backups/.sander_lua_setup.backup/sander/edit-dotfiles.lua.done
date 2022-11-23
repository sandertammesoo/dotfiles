-- edit-dotfiles.lua

local M = {} -- initialize an empty table (or object in JS terms)

function M.edit_neovim()
	require("telescope.builtin").git_files({
		shorten_path = true,
		cwd = "~/.dotfiles",
		prompt = "~ dotfiles",
		height = 10,
		layout_stategy = "horisontal",
		layout_options = {
			preview_width = 0.75,
		},
	})
end

return M
