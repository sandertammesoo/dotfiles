-- n, v, i, t = mode names

local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local M = {}

M.general = {
  i = { -- {{{
    -- use jk to exit insert mode
    ["jk"] = { "<ESC>", "exit insert mode" },

    -- go to  beginning and end
    ["<C-b>"] = { "<ESC>^i", "beginning of line" },
    ["<C-e>"] = { "<End>", "end of line" },

    -- navigate within insert mode
    ["<C-h>"] = { "<Left>", "move left" },
    ["<C-l>"] = { "<Right>", "move right" },
    ["<C-j>"] = { "<Down>", "move down" },
    ["<C-k>"] = { "<Up>", "move up" },
  },

  n = {
    ["<ESC>"] = { "<cmd> noh <CR>", "no highlight" },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "window left" },
    ["<C-l>"] = { "<C-w>l", "window right" },
    ["<C-j>"] = { "<C-w>j", "window down" },
    ["<C-k>"] = { "<C-w>k", "window up" },

    -- save
    ["<C-s>"] = { "<cmd> w <CR>", "save file" },
    ["<C-s><C-a>"] = { "<cmd> wa <CR>", "save all files" },

    -- Copy all
    ["<C-c>"] = { "<cmd> %y+ <CR>", "copy whole file" },

    -- line numbers
    ["<leader>n"] = { "<cmd> set nu! <CR>", "toggle line number" },
    ["<leader>rn"] = { "<cmd> set rnu! <CR>", "toggle relative number" },

    -- quit
    -- ["<C-q>"] = { "<cmd> q <CR>", "close file" },
    ["<C-q><C-a>"] = { "<cmd> qa <CR>", "quit" },

    -- delete single character without copying into register
    ["x"] = { '"_x' },

    -- increment/decrement numbers
    ["<leader>+"] = { "<C-a>", "increment number" },
    ["<leader>-"] = { "<C-x>", "decrement number" },

    -- Toggle theme
    ["<leader>tt"] = {
      function()
        require("base46").toggle_theme()
      end,
      "toggle theme",
    },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },

    -- new buffer
    ["<leader>b"] = { "<cmd> enew <CR>", "new buffer" },

    -- Currently not workig properly with NvChad loading logic :/
    -- ["<leader><leader>x"] = { ":call tj#save_and_exec()<CR>", "Reload all saved nvim conf" },

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

  t = { ["<C-x>"] = { termcodes "<C-\\><C-N>", "escape terminal mode" } },

  v = {
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
  },

  x = {
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', opts = { silent = true } },
  },
} -- }}}

M.tabufline = {
  plugin = true, -- {{{

  n = {
    -- cycle through buffers
    ["<TAB>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflineNext()
      end,
      "goto next buffer",
    },

    ["<S-Tab>"] = {
      function()
        require("nvchad_ui.tabufline").tabuflinePrev()
      end,
      "goto prev buffer",
    },

    -- pick buffers via numbers
    ["<Bslash>"] = { "<cmd> TbufPick <CR>", "Pick buffer" },

    -- close buffer + hide terminal buffer
    ["<leader>x"] = {
      function()
        require("nvchad_ui.tabufline").close_buffer()
      end,
      "close buffer",
    },
  },
} -- }}}

M.comment = {
  plugin = true, -- {{{

  -- toggle comment in both modes
  n = {
    ["<leader>/"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "toggle comment",
    },
  },

  v = {
    ["<leader>/"] = {
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      "toggle comment",
    },
  },
} -- }}}

M.lspconfig = {
  plugin = true, -- {{{

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {

    ["gf"] = {
      -- function()
      --   vim.lsp.buf.definition()
      -- end,
      "<cmd>Lspsaga lsp_finder<CR>",
      "show definition, references (lspsaga)",
    },

    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "go to declaration (lsp)",
    },

    ["gd"] = {
      -- function()
      --   vim.lsp.buf.definition()
      -- end,
      "<cmd>Lspsaga peek_definition<CR>",
      "see definition and edit (lspsaga)",
    },

    ["K"] = {
      -- function()
      --   vim.lsp.buf.hover()
      -- end,
      "<cmd>Lspsaga hover_doc<CR>",
      "show documentation (lspsaga)",
    },

    ["gi"] = {
      function()
        vim.lsp.buf.implementation()
      end,
      "go to implementation (lsp)",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "lsp signature_help",
    },

    ["<leader>D"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "lsp definition type",
    },

    ["<leader>r"] = {
      function()
        vim.lsp.buf.rename()
      end,
      "rename (lsp)",
    },

    ["<leader>rn"] = {
      "<cmd>Lspsaga rename<CR>",
      "rename (lspsaga)",
    },

    ["<leader>ra"] = {
      function()
        require("nvchad_ui.renamer").open()
      end,
      "rename (nvchad)",
    },

    ["<leader>ca"] = {
      -- function()
      --   vim.lsp.buf.code_action()
      -- end,
      "<cmd>Lspsaga code_action<CR>",
      "see code actions (lspsaga)",
    },

    ["gr"] = {
      "<cmd> Telescope lsp_references<CR>",
      "show references (tele)",
    },
    -- ["gr"] = {
    --   function()
    --     vim.lsp.buf.references()
    --   end,
    --   "lsp references",
    -- },

    ["<leader>f"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "goto prev",
    },

    ["d]"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "goto_next",
    },

    ["<leader>q"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "diagnostic setloclist",
    },

    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "lsp formatting",
    },

    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "add workspace folder",
    },

    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "remove workspace folder",
    },

    ["<leader>wl"] = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "list workspace folders",
    },

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

    ["<leader>o"] = {
      "<cmd>LSoutlineToggle<CR>",
      "see outline",
    },

    --   Ideas for more keybinds{{{
    -- set keybinds
    -- keymap.set("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
    -- keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
    -- keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
    -- keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer

    -- typescript specific keymaps (e.g. rename file and update imports)
    -- if client.name == "tsserver" then
    --   keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
    --   keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
    --   keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
    -- end
    -- }}}
  },
} -- }}}

M.nvimtree = {
  plugin = true, -- {{{

  n = {
    -- toggle
    ["<C-n>"] = { "<cmd> NvimTreeToggle <CR>", "toggle nvimtree" },

    -- focus
    ["<leader>e"] = { "<cmd> NvimTreeFocus <CR>", "focus nvimtree" },

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
} -- }}}

M.telescope = {
  plugin = true, -- {{{

  n = {
    -- find
    ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "find files" },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "find all" },
    ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "find oldfiles" },
    ["<leader>tk"] = { "<cmd> Telescope keymaps <CR>", "show keys" },
    ["<leader>fk"] = { "<cmd> Telescope keymaps <CR>", "show keys" },
    -- ["<leader>fp"] = { "<cmd> Telescope project <CR>", "show projects" },
    -- ["<leader>fr"] = { "<cmd> lua require'telescope'.extensions.repo.cached_list{locate_opts={'-d', vim.env.HOME .. '/locatedb'}} <CR>", "show repos" },
    -- ["<leader>fb"] = { "<cmd> lua require'telescope'.extensions.file_browser.file_browser{} <CR>", "show file browser" },

    -- git
    ["<leader>cm"] = { "<cmd> Telescope git_commits <CR>", "git commits" },
    ["<leader>gc"] = { "<cmd> Telescope git_commits <CR>", "git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "git status" },
    ["<leader>gs"] = { "<cmd> Telescope git_status <CR>", "git status" },
    ["<leader>gfc"] = { "<cmd> Telescope git_bcommits <CR>", "git commits for current file" },
    ["<leader>gbr"] = { "<cmd> Telescope git_branches <CR>", "git branches" },

    -- command palette
    -- ["<leader>cp"] = { "<cmd> Telescope command_palette <CR>", "show command palette" },

    -- pick a hidden term
    ["<leader>pt"] = { "<cmd> Telescope terms <CR>", "pick hidden term" },

    -- theme switcher
    ["<leader>th"] = { "<cmd> Telescope themes <CR>", "nvchad themes" },
  },
} -- }}}

M.nvterm = {
  plugin = true, -- {{{

  t = {
    -- toggle in terminal mode
    ["<A-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "toggle vertical term",
    },
  },

  n = {
    -- toggle in normal mode
    ["<A-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "toggle vertical term",
    },

    -- new

    ["<leader>h"] = {
      function()
        require("nvterm.terminal").new "horizontal"
      end,
      "new horizontal term",
    },

    ["<leader>v"] = {
      function()
        require("nvterm.terminal").new "vertical"
      end,
      "new vertical term",
    },

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
} -- }}}

M.whichkey = {
  plugin = true, -- {{{

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd "WhichKey"
      end,
      "which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input "WhichKey: "
        vim.cmd("WhichKey " .. input)
      end,
      "which-key query lookup",
    },
  },
} -- }}}

M.blankline = {
  plugin = true, -- {{{

  n = {
    ["<leader>cc"] = {
      function()
        local ok, start = require("indent_blankline.utils").get_current_context(
          vim.g.indent_blankline_context_patterns,
          vim.g.indent_blankline_use_treesitter_scope
        )

        if ok then
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start, 0 })
          vim.cmd [[normal! _]]
        end
      end,

      "Jump to current_context",
    },
  },
} -- }}}

M.gitsigns = {
  plugin = true, -- {{{

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },

    ["[c"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>rh"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    ["<leader>ph"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },

    ["<leader>gb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },

    ["<leader>td"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle deleted",
    },
  },
} -- }}}

-- M.vimmaximizer = {
--   plugin = true,{{{
--
--   n = {
--     -- toggle maximization
--     ["<leader>sm"] = { "<cmd> MaximizerToggle <CR>", "toggle split window maximization" },
--   },
-- }}}}

-- M.diffview = {
--   plugin = true,{{{
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
-- }}}}

-- local function cd_dot_cb(node)
--   nvimtree.change_dir(vim.fn.getcwd(-1))
--   if node.name ~= ".." then
--     require("nvim-tree.lib").set_index_and_redraw(node.absolute_path)
--   end
-- end

return M
