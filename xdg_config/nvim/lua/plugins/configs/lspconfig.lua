local present, lspconfig = pcall(require, "lspconfig")

if not present then
  return
end

require("base46").load_highlight "lsp"
require "nvchad_ui.lsp"

local M = {}
local utils = require "core.utils"

local is_mac = vim.fn.has "macunix" == 1
local lspconfig_util = require "lspconfig.util"
local ts_util = require "nvim-lsp-ts-utils"
local augroup_format = vim.api.nvim_create_augroup("custom-lsp-format", { clear = true })
local autocmd_format = function(async, filter)
  vim.api.nvim_clear_autocmds { buffer = 0, group = augroup_format }
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
      vim.lsp.buf.format { async = async, filter = filter }
    end,
  })
end
-- export on_attach & capabilities for custom lspconfigs

local filetype_attach = setmetatable({

  css = function()
    autocmd_format(false)
  end,

  typescript = function()
    autocmd_format(false, function(client)
      return client.name ~= "tsserver"
    end)
  end,
}, {
  __index = function()
    return function() end
  end,
})

M.on_init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

M.on_attach = function(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")

  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end

  -- Attach any filetype specific options to the client
  filetype_attach[filetype](client)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
-- Completion configuration
require("cmp_nvim_lsp").default_capabilities(M.capabilities)

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

lspconfig.sumneko_lua.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

-- configure typescript server with plugin
-- require("jose-elias-alvarez/typescript.nvim").setup {
lspconfig.tsserver.setup {
  disable_commands = false, -- prevent the plugin from creating Vim commands
  debug = true, -- enable debug logging for commands
  go_to_source_definition = {
    fallback = true, -- fall back to standard LSP definition on failure
  },
  server = {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
}

-- local servers = { "html", "cssls", "clangd" }
--
-- for _, server in ipairs(servers) do
--   lspconfig[server].setup {
--     on_attach = M.on_attach,
--     capabilities = M.capabilities,
--   }
-- end

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local servers = {
  -- Also uses `shellcheck` and `explainshell`
  bashls = true,

  eslint = true,
  -- gdscript = true,
  -- graphql = true,
  html = true,
  -- pyright = true,
  vimls = true,
  yamlls = true,

  cmake = (1 == vim.fn.executable "cmake-language-server"),
  -- dartls = pcall(require, "flutter-tools"),

  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--suggest-missing-includes",
      "--clang-tidy",
      "--header-insertion=iwyu",
    },
    init_options = {
      clangdFileStatus = true,
    },
  },

  -- gopls = {
  --   -- root_dir = function(fname)
  --   --   local Path = require "plenary.path"
  --   --
  --   --   local absolute_cwd = Path:new(vim.loop.cwd()):absolute()
  --   --   local absolute_fname = Path:new(fname):absolute()
  --   --
  --   --   if string.find(absolute_cwd, "/cmd/", 1, true) and string.find(absolute_fname, absolute_cwd, 1, true) then
  --   --     return absolute_cwd
  --   --   end
  --   --
  --   --   return lspconfig_util.root_pattern("go.mod", ".git")(fname)
  --   -- end,
  --
  --   settings = {
  --     gopls = {
  --       codelenses = { test = true },
  --     },
  --   },
  --
  --   flags = {
  --     debounce_text_changes = 200,
  --   },
  -- },

  -- omnisharp = {
  --   cmd = { vim.fn.expand "~/build/omnisharp/run", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  -- },
  --
  -- rust_analyzer = rust_analyzer,
  --
  -- racket_langserver = true,
  --
  -- elmls = true,
  cssls = true,
  tsserver = {
    init_options = ts_util.init_options,
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },

    on_attach = function(client)
      M.on_attach(client)

      ts_util.setup { auto_inlay_hints = false }
      ts_util.setup_client(client)
    end,
  },
}

local setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = vim.tbl_deep_extend("force", {
    on_init = M.on_init,
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    flags = {
      debounce_text_changes = nil,
    },
  }, config)

  lspconfig[server].setup(config)
end

if is_mac then
  local sumneko_cmd, sumneko_env = nil, nil
  require("nvim-lsp-installer").setup {
    automatic_installation = false,
    ensure_installed = { "sumneko_lua" }, -- TODO: Maybe can add all LSPs here??
  }

  sumneko_cmd = {
    vim.fn.stdpath "data" .. "/lsp_servers/sumneko_lua/extension/server/bin/lua-language-server",
  }

  local process = require "nvim-lsp-installer.core.process"
  local path = require "nvim-lsp-installer.core.path"

  sumneko_env = {
    cmd_env = {
      PATH = process.extend_path {
        path.concat { vim.fn.stdpath "data", "lsp_servers", "sumneko_lua", "extension", "server", "bin" },
      },
    },
  }

  setup_server("sumneko_lua", {
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            -- vim
            "vim",

            -- Busted
            "describe",
            "it",
            "before_each",
            "after_each",
            "teardown",
            "pending",
            "clear",

            -- Colorbuddy
            "Color",
            "c",
            "Group",
            "g",
            "s",

            -- Custom
            "RELOAD",
          },
        },

        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },
  })
else
  -- Load lua configuration from nlua.
  _ = require("nlua.lsp.nvim").setup(lspconfig, {
    on_init = M.on_init,
    on_attach = M.on_attach,
    capabilities = M.capabilities,

    root_dir = function(fname)
      if string.find(vim.fn.fnamemodify(fname, ":p"), "xdg_config/nvim/") then
        return vim.fn.expand "~/git/config_manager/xdg_config/nvim/"
      end

      -- ~/git/config_manager/xdg_config/nvim/...
      return lspconfig_util.find_git_ancestor(fname) or lspconfig_util.path.dirname(fname)
    end,

    globals = {
      -- Colorbuddy
      "Color",
      "c",
      "Group",
      "g",
      "s",

      -- Custom
      "RELOAD",
    },
  })
end

for server, config in pairs(servers) do
  setup_server(server, config)
end
return M
