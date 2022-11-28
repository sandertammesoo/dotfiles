local M = {}

-- M.telescope = {}

-- M.lspconfig = {
--
-- }

-- M.nvimcmp = {
--   snippet = {
--     expand = function(args)
--       require("luasnip").lsp_expand(args.body)
--     end,
--   },
--   formatting = {
--     format = function(_, vim_item) -- For showing form which source the completion comes from on the right of the completion suggestion box
--       local icons = require("nvchad_ui.icons").lspkind
--       vim_item.kind = string.format("%s %s %s", icons[vim_item.kind], vim_item.kind)
--       return vim_item
--     end,
--   },
--   sources = {
--     { name = "nvim_lua" },
--     { name = "nvim_lsp" },
--     { name = "path" },
--     { name = "luasnip" },
--     { name = "buffer", keyword_length = 5 }, -- max_item_count = 3 },
--   },
--   experimental = {
--     native_menu = false,
--     ghost_text = true,
--   },
-- }
M.cmpnvimlsp = {}
M.cmpnvimlua = {}
M.cmpbuffer = {}
M.cmppath = {}
M.luasnip = {}

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
  view = {
    relativenumber = true,
    --   -- preserve_window_proportions = true,
    --   mappings = {
    --     { key = ".", action = "cd_dot", action_cb = cd_dot_cb }, -- run_file_command
    --   },
  },
}

M.whichkey = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  operators = { gc = "Comments" },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = "<c-d>", -- binding to scroll down inside the popup
    scroll_up = "<c-u>", -- binding to scroll up inside the popup
  },
  window = {
    border = "none", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    winblend = 0,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  show_keys = true, -- show the currently pressed key and its label as a message in the command line
  triggers = "auto", -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },
  -- disable the WhichKey popup for certain buf types and file types.
  -- Disabled by deafult for Telescope
  disable = {
    buftypes = {},
    filetypes = { "TelescopePrompt" }, -- should add Terminal here?
  },
}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "typescript",
    "c",
    "comment",
    "cpp",
    "diff",
    "dockerfile",
    "dot",
    "gitattributes",
    "gitignore",
    "graphql",
    "http",
    "javascript",
    "json",
    "latex",
    "make",
    "php",
    "markdown",
    "phpdoc",
    "regex",
    "sql",
    "yaml",
    "toml",
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "emmet-ls",
    "json-lsp",

    -- -- shell
    -- "shfmt",
    -- "shellcheck",
  },
}

M.nvterm = {
  terminals = {
    type_opts = {
      float = {
        relative = "editor",
        row = 0.1, -- 2*row + height = 1 for center align
        height = 0.8,
        col = 0.15, -- 2*col + width = 1 for center align
        width = 0.7,
        border = "single",
      },
    },
  },
}

return M
