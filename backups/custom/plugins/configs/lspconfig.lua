-- custom.plugins.lspconfig
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "clangd"}

-- -- Change the Diagnostic symbols in the sign column (gutter)
-- -- (not in youtube nvim video)
-- local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
-- end

-- -- configure html server
-- lspconfig.html.setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })

-- configure typescript server with plugin
-- require("jose-elias-alvarez/typescript.nvim").setup({
--   server = {
--     capabilities = M.capabilities,
--     on_attach = M.on_attach,
--   },
--   filetypes = {
--     'javascript',
--     'javascriptreact',
--     'javascript.jsx',
--     'typescript',
--     'typescriptreact',
--     'typescript.tsx',
--   },
-- })

-- -- configure css server
-- lspconfig.cssls.setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })
--
-- -- configure tailwindcss server
-- lspconfig.tailwindcss.setup({
--   capabilities = capabilities,
--   on_attach = on_attach,
-- })

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
