-- import null-ls plugin safely
local present, null_ls = pcall(require, "null-ls")
if not present then
  return
end

-- for conciseness
local formatting = null_ls.builtins.formatting -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters

-- to setup format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
  --  to disable file types use
  --  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)

  -- webdev stuff
  formatting.deno_fmt,
  formatting.prettier,

  -- Lua
  formatting.stylua,

  -- Shell
  formatting.shfmt,
  diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
  diagnostics.eslint_d.with { -- js/ts linter
    -- only enable eslint if root has .eslintrc.js (not in youtube nvim video)
    condition = function(utils)
      return utils.root_has_file ".eslintrc.js" -- change file extension if you use something else
    end,
  },
  require "typescript.extensions.null-ls.code-actions",
}

-- configure null_ls
null_ls.setup {
  -- setup formatters & linters
  sources = sources,
  debug = true,

  -- configure format on save
  on_attach = function(current_client, bufnr)
    if current_client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format {
            filter = function(client)
              --  only use null-ls for formatting instead of lsp server
              return client.name == "null-ls"
            end,
            bufnr = bufnr,
          }
        end,
      })
    end
  end,
}
