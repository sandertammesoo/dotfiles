-- edit-dotfiles.lua

local M = {} -- initialize an empty table (or object in JS terms)

function M.edit_neovim()
  require("telescope.builtin").git_files {
    attach_mappings = function(_, map)
      map("i", "<C-k>", require("telescope.actions").move_selection_previous) -- move to prev result
      map("i", "<C-j>", require("telescope.actions").move_selection_next) -- move to next result
      map("i", "<C-q>", require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist) -- send selected to quickfixlist
      map("i", "<C-c>", require("telescope.actions").close) -- send selected to quickfixlist
      return false
    end,
    shorten_path = true,
    cwd = "~/.dotfiles",
    prompt = "~ dotfiles",
    height = 10,
    layout_stategy = "horisontal",
    layout_options = {
      preview_width = 0.75,
    },
  }
end

return M
