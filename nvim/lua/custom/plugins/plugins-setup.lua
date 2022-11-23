local overrides = require "custom.plugins.configs.overrides"

-- local function cd_dot_cb(node)
--   nvimtree.change_dir(vim.fn.getcwd(-1))
--   if node.name ~= ".." then
--     require("nvim-tree.lib").set_index_and_redraw(node.absolute_path)
--   end
-- end

return {
  -- overrde plugin configs
  -- ["nvim-treesitter/nvim-treesitter"] = {
  --   override_options = overrides.treesitter,
  -- },
  --
  -- ["williamboman/mason.nvim"] = {
  --   override_options = overrides.mason,
  -- },

  ["kyazdani42/nvim-tree.lua"] = {
    override_options = overrides.nvimtree,
  },

  ["nvim-telescope/telescope.nvim"] = {},
  --   override_options = {
  --     defaults = {
  --       mappings = {
  --         i = {
  --           ["<C-k>"] = require("telescope.actions").move_selection_previous, -- move to prev result
  --           ["<C-j>"] = require("telescope.actions").move_selection_next, -- move to next result
  --           ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist, -- send selected to quickfixlist
  --         },
  --       },
  --     },
  --   },
  -- },

  -- -- Override plugin definition options
  -- ["goolord/alpha-nvim"] = {
  --   disable = false,
  --   cmd = "Alpha",
  -- },
  --
  -- -- Override plugin config
  -- ["williamboman/mason.nvim"] = {
  --   override_options = {
  --         ensure_installed = { "html-lsp", "clangd" }
  --     }
  -- },
  --
  --  -- Override plugin config if it has a module called
  --  -- If you wish to call a module, which is 'cmp' in this case
  --  ["hrsh7th/nvim-cmp"] = {
  --   override_options = function()
  --     local cmp = require "cmp"
  --
  --     return {
  --       mapping = {
  --         ["<C-d>"] = cmp.mapping.scroll_docs(-8),
  --       },
  --     }
  --   end,
  -- },

  -- install a plugin
  -- ["neovim/nvim-lspconfig"] = {
  --   config = function()
  --     require "plugins.configs.lspconfig"
  --     require "custom.plugins.configs.lspconfig"
  --   end,
  -- },
  --
  -- ["Nsindrets/diffview"] = {
  --   config = function()
  --     local present, diffview = pcall(require, "diffview")
  --
  --     if present then
  --       diffview.setup()
  --     end
  --   end,
  -- },
  --
  -- -- code formatting, linting etc
  -- ["jose-elias-alvarez/null-ls.nvim"] = {
  --   after = "nvim-lspconfig",
  --   config = function()
  --     require "custom.plugins.configs.null-ls"
  --   end,
  -- },

  -- remove plugin
  -- ["hrsh7th/cmp-path"] = false,

  -- ["bluz71/vim-nightfly-guicolors"] = {}
  -- use("szw/vim-maximizer") -- maximizes and restores current window
  -- use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
  -- use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)
  -- use("nvim-lualine/lualine.nvim")

  -- use({ "glepnir/lspsaga.nvim", branch = "main" }) -- enhanced lsp uis
  -- use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  -- use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

  -- -- formatting & linting
  -- use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
  -- use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls
  -- use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags
  -- use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  -- use({ "nvim-telescope/telescope-project.nvim" }) --
  -- use({ "nvim-telescope/telescope-file-browser.nvim" }) --
  -- use({ "cljoly/telescope-repo.nvim" }) --
  -- use({ "LinArcX/telescope-command-palette.nvim" }) --
  -- use({ "NvChad/base46" }) --
  -- use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" }) -- fuzzy finder
  -- use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig
  -- ["LinArcX/telescope-command-palette.nvim"] = {},

  -- NOTE : The override_options will override the default
  -- plugin config's options, so you don't have to re-write
  -- the whole default plugin config but rather write only
  -- the things you want to change (overwrite).
  --[[
  -- -- Install plugin
  -- ["Pocco81/TrueZen.nvim"] = {},
  --
  --
  -- -- remove plugin
  -- ["neovim/nvim-lspconfig"] = false

--   ["NvChad/ui"] = {
--  override_options = {
--    tabufline = {
--      lazyload = false, -- to show tabufline by default
--      overriden_modules = function()
--        return require "custom.configs.xyz"
--      end,
--    },
--  },
-- },
--]]
  -- We are just modifying lspconfig's packer definition table
  -- Put this in your custom plugins section i.e M.plugins field
}