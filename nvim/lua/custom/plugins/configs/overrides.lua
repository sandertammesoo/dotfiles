local M = {}

M.telescope = {}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },
  open_on_setup = true,
  open_on_setup_file = true,
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
  -- view = {
  --   -- preserve_window_proportions = true,
  --   mappings = {
  --     { key = ".", action = "cd_dot", action_cb = cd_dot_cb }, -- run_file_command
  --   },
  -- },
}

-- M.treesitter = {
--   ensure_installed = {
--     "vim",
--     "lua",
--     "html",
--     "css",
--     "typescript",
--     "c",
--   },
-- }

-- M.mason = {
--   ensure_installed = {
--     -- lua stuff
--     "lua-language-server",
--     "stylua",
--
--     -- web dev
--     "css-lsp",
--     "html-lsp",
--     "typescript-language-server",
--     "deno",
--     "emmet-ls",
--     "json-lsp",
--
--     -- shell
--     "shfmt",
--     "shellcheck",
--   },
-- }

return M
