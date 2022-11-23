local present, mason = pcall(require, "mason")

if not present then
  return
end

vim.api.nvim_create_augroup("_mason", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
  pattern = "mason",
  callback = function()
    require("base46").load_highlight "mason"
  end,
  group = "_mason",
})

local options = {
  ensure_installed = { "lua-language-server" }, -- not an option from mason.nvim

  PATH = "skip",

  ui = {
    icons = {
      package_pending = " ",
      package_installed = " ",
      package_uninstalled = " ﮊ",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 10,
}

options = require("core.utils").load_override(options, "williamboman/mason.nvim")

vim.api.nvim_create_user_command("MasonInstallAll", function()
  vim.cmd("MasonInstall " .. table.concat(options.ensure_installed, " "))
end, {})

mason.setup(options)

-- mason_lspconfig.setup({
-- 	-- list of servers for mason to install
-- 	ensure_installed = {
-- 		"tsserver",
-- 		"quick_lint_js",
-- 		"html",
-- 		"cssls",
-- 		"tailwindcss",
-- 		"sumneko_lua",
-- 		-- "emmet_ls",
-- 	},
-- 	-- auto-install configured servers (with lspconfig)
-- 	automatic_installation = true, -- not the same as ensure_installed
-- })
--
-- mason_null_ls.setup({
-- 	-- list of formatters & linters for mason to install
-- 	ensure_installed = {
-- 		"prettier", -- ts/js formatter
-- 		"stylua", -- lua formatter
-- 		"eslint_d", -- ts/js linter
-- 	},
-- 	-- auto-install configured formatters & linters (with null-ls)
-- 	automatic_installation = true,
-- })
