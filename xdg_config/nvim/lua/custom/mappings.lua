-- lua/custom/mappings
local M = {}
-- add this table only when you want to disable default keys
-- M.disabled = {
--   n = {
--     ["<leader>tk"] = "",
--     ["<leader>cm"] = "",
--     ["<leader>gt"] = "",
--   },
-- }
---------------------
-- General Keymaps
---------------------

M.general = {
  i = {
    -- use jk to exit insert mode
    ["jk"] = { "<ESC>", "exit insert mode" },
  },

  n = {
    -- ["<leader>sv"] = { "<C-w>v", "split window vertically" },
    -- ["<leader>sh"] = { "<C-w>h", "split window horisontally" },
    -- ["<leader>se"] = { "<C-w>+", "make slipts equal" },
    -- ["<leader>sx"] = { "<cmd> close <CR>", "close current split" },

    -- save
    ["<C-s><C-a>"] = { "<cmd> wa <CR>", "save all files" },

    -- quit
    -- ["<C-q>"] = { "<cmd> q <CR>", "close file" },
    ["<C-q><C-a>"] = { "<cmd> qa <CR>", "quit" },

    -- delete single character without copying into register
    ["x"] = { '"_x' },

    -- increment/decrement numbers
    ["<leader>+"] = { "<C-a>", "increment number" },
    ["<leader>-"] = { "<C-x>", "decrement number" },
    ["<leader><leader>x"] = { "<cmd> PackerSync <CR>", "PackerSync" },
    ["<leader><leader>z"] = { "<cmd> PackerCompile <CR>", "PackerCompile" },

    -- " Change the current word in insertmode.
    -- "   Auto places you into the spot where you can start typing to change it.
    -- nnoremap <c-w><c-r> :%s/<c-r><c-w>//g<left><left>
    -- " Move line(s) up and down
    -- inoremap <M-j> <Esc>:m .+1<CR>==gi
    -- inoremap <M-k> <Esc>:m .-2<CR>==gi
    -- vnoremap <M-j> :m '>+1<CR>gv=gv
    -- vnoremap <M-k> :m '<-2<CR>gv=gv

    -- tabs
    -- -- Switch between tabs
    -- vim.keymap.set("n", "<Right>", function()
    --   vim.cmd [[checktime]]
    --   vim.api.nvim_feedkeys("gt", "n", true)
    -- end)
    --
    -- vim.keymap.set("n", "<Left>", function()
    --   vim.cmd [[checktime]]
    --   vim.api.nvim_feedkeys("gT", "n", true)
    -- end)
    -- ["<leader>to"] = { "<cmd> tabnew <CR>", "new tab" },
    -- ["<leader>tx"] = { "<cmd> tabclose <CR>", "close tab" },
    -- ["<leader>tn"] = { "<cmd> tabn <CR>", "next tab" },
    -- ["<leader>tp"] = { "<cmd> tabp <CR>", "prev tab" }, -- maybe switch to <SC-TAB>

    -- edit dotfiles
    ["<leader>ed"] = { "<cmd> lua require'custom.edit-dotfiles'.edit_neovim() <CR>", "edit dotfiles" },
  },
}

-- -- Copied from xdg_config/nvim/lua/core/mappings.lua
-- M.tabufline = {
--   plugin = true,
--
--   n = {
--     -- cycle through buffers
--     ["<TAB>"] = {
--       function()
--         require("nvchad_ui.tabufline").tabuflineNext()
--       end,
--       "goto next buffer",
--     },
--
--     ["<S-Tab>"] = {
--       function()
--         require("nvchad_ui.tabufline").tabuflinePrev()
--       end,
--       "goto prev buffer",
--     },
--
--     -- pick buffers via numbers
--     ["<Bslash>"] = { "<cmd> TbufPick <CR>", "Pick buffer" },
--
--     -- close buffer + hide terminal buffer
--     ["<leader>x"] = {
--       function()
--         require("nvchad_ui.tabufline").close_buffer()
--       end,
--       "close buffer",
--     },
--   },
-- }

M.lspconfig = {
  n = {
    ["<leader>dl"] = {
      "<cmd>Telescope diagnostics<CR>",
      "Telescope diagnostics",
    },

    ["<leader>dk"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "goto prev",
    },

    ["<leader>dj"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "goto_next",
    },

    ["<leader>r"] = {
      function()
        vim.lsp.buf.rename()
      end,
      "rename",
    },

    ["gr"] = {
      "<cmd> Telescope lsp_references<CR>",
      "lsp references",
    },
  },
  --   plugin = true,
  --
  --   -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions
  --
  --   -- -- set keybinds
  --   -- keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
  --   -- keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
  --   -- keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
  --   -- keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
  --   -- keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
  --   -- keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
  --   -- keymap.set("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
  --   -- keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
  --   -- keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
  --   -- keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
  --   -- keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
  --   -- keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side
  --   --
  --   -- -- typescript specific keymaps (e.g. rename file and update imports)
  --   -- if client.name == "tsserver" then
  --   --   keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
  --   --   keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
  --   --   keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
  --   -- end
}

-- M.vimmaximizer = {
--   plugin = true,
--
--   n = {
--     -- toggle maximization
--     ["<leader>sm"] = { "<cmd> MaximizerToggle <CR>", "toggle split window maximization" },
--   },
-- }

-- M.diffview = {
--   plugin = true,
--
--   n = {
--     -- general
--     ["<leader>do"] = { "<cmd> DiffviewOpen <CR>", "open diffview" },
--     ["<leader>dx"] = { "<cmd> DiffviewClose <CR>", "close diffview" },
--     ["<leader>de"] = { "<cmd> DiffviewToggleFiles <CR>", "toggle files in diffview" },
--     ["<leader>du"] = { "<cmd> DiffviewRefresh <CR>", "refresh diffview" },
--
--     -- history
--     ["<leader>dha"] = { "<cmd> DiffviewFileHistory <CR>", "all history diffview" },
--     ["<leader>dhf"] = { "<cmd> DiffviewFileHistory % <CR>", "cur file history diffview" },
--   },
-- }

-- local function cd_dot_cb(node)
--   nvimtree.change_dir(vim.fn.getcwd(-1))
--   if node.name ~= ".." then
--     require("nvim-tree.lib").set_index_and_redraw(node.absolute_path)
--   end
-- end

M.nvimtree = {
  plugin = true,

  n = {
    -- find file
    ["<leader>ef"] = { "<cmd> NvimTreeFindFile <CR>", "focus current file in nvimtree" },

    -- marks
    ["<leader>mn"] = {
      function()
        require("nvim-tree.api").marks.navigate.next()
      end,
      "next mark",
    },
    ["<leader>mp"] = {
      function()
        require("nvim-tree.api").marks.navigate.prev()
      end,
      "prev mark",
    },
    ["<leader>ms"] = {
      function()
        require("nvim-tree.api").marks.navigate.select()
      end,
      "select mark",
    },
    ["<leader>ml"] = {
      function()
        require("nvim-tree.api").marks.list()
      end,
      "list  marks",
    },
  },
}

M.telescope = {
  plugin = true,

  --[[
  -- HACK: NOT WORKING PROPERLY HERE / IMPLEMENTED IN lua/plugins/telescope.lua
  i = {
    ["<C-k>"] = {
      function()
        require("telescope.actions").move_selection_previous()
      end,
      "move to prev result",
    },
    ["<C-j>"] = {
      function()
        require("telescope.actions").move_selection_next()
      end,
      "move to next result",
    },
    ["<C-q>"] = {
      function()
        require("telescope.actions").send_selection_to_qflist()
      end,
      "send to quickfixlist",
    },
  },
  --]]

  n = {
    -- find
    ["<leader>fk"] = { "<cmd> Telescope keymaps <CR>", "show keys" },
    -- ["<leader>fp"] = { "<cmd> Telescope project <CR>", "show projects" },
    -- ["<leader>fr"] = { "<cmd> lua require'telescope'.extensions.repo.cached_list{locate_opts={'-d', vim.env.HOME .. '/locatedb'}} <CR>", "show repos" },
    -- ["<leader>fb"] = { "<cmd> lua require'telescope'.extensions.file_browser.file_browser{} <CR>", "show file browser" },

    -- git
    ["<leader>gc"] = { "<cmd> Telescope git_commits <CR>", "git commits" },
    ["<leader>gs"] = { "<cmd> Telescope git_status <CR>", "git status" },
    ["<leader>gfc"] = { "<cmd> Telescope git_bcommits <CR>", "git commits for current file" },
    ["<leader>gbr"] = { "<cmd> Telescope git_branches <CR>", "git branches" },

    -- command palette
    -- ["<leader>cp"] = { "<cmd> Telescope command_palette <CR>", "show command palette" },
  },
}

M.nvterm = {
  plugin = true,

  n = {
    -- toggle maximization
    ["<leader>sm"] = { "<cmd> MaximizerToggle <CR>", "toggle split window maximization" },

    ["<leader>lgf"] = {
      function()
        -- require("nvterm.terminal").new "horizontal"
        require("nvterm.terminal").send(" lazygit ", "float") -- the 2nd argument i.e direction is optional
      end,
      "Open Lazygit in float terminal",
    },

    ["<leader>lgh"] = {
      function()
        -- require("nvterm.terminal").new "horizontal"
        require("nvterm.terminal").send(" lazygit ", "horizontal") -- the 2nd argument i.e direction is optional
      end,
      "Open Lazygit in horisontal terminal",
    },

    ["<leader>lgv"] = {
      function()
        -- require("nvterm.terminal").new "horizontal"
        require("nvterm.terminal").send(" lazygit ", "vertical") -- the 2nd argument i.e direction is optional
      end,
      "Open Lazygit in vertical terminal",
    },
  },
}

return M
