local overrides = require "custom.plugins.configs.overrides"
-- local autocmd = vim.api.nvim_create_autocmd

return {
  -- overrde plugin configs
  ["nvim-treesitter/nvim-treesitter"] = { -- For syntax highlighting
    override_options = overrides.treesitter,
  },

  ["williamboman/mason.nvim"] = {
    override_options = overrides.mason,
  },

  ["kyazdani42/nvim-tree.lua"] = { -- Left-side file explorer
    override_options = overrides.nvimtree,
  },

  ["nvim-telescope/telescope.nvim"] = { -- Fuzzy finder
    override_options = overrides.telescope,
  },

  ["folke/which-key.nvim"] = { -- Keymappings cheatsheet helper
    disable = false,
    cmd = "WhichKey",
    override_options = overrides.whichkey,
  },

  -- Override plugin definition options
  -- TODO: Use vim-startify instead? https://github.com/mhinz/vim-startify
  ["goolord/alpha-nvim"] = { -- Neovim start dashboard view
    disable = false,
  },

  -- install a plugin
  ["neovim/nvim-lspconfig"] = { -- Language Server Protocol / for syntax errors
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.configs.lspconfig"
    end,
  },

  ["jose-elias-alvarez/null-ls.nvim"] = { -- code formatting, linting etc
    after = "nvim-lspconfig",
    config = function()
      require "custom.plugins.configs.null-ls"
    end,
  },

  ["hrsh7th/nvim-cmp"] = {
    -- override_options = overrides.nvimcmp,
    config = function()
      require "plugins.configs.cmp"
      require "custom.plugins.configs.cmp"
    end,
  },

  ["hrsh7th/cmp-nvim-lua"] = { -- When writing lua, it has special nvim knowlede and does good completions
    override_options = overrides.cmpnvimlua,
  },

  ["hrsh7th/cmp-nvim-lsp"] = { -- To get super easy auto imports on completes
    override_options = overrides.cmpnvimlsp,
  },

  ["hrsh7th/cmp-buffer"] = { -- Completes words from the current buffer that your in
    override_options = overrides.cmpbuffer,
  },

  ["hrsh7th/cmp-path"] = { -- Completes files
    override_options = overrides.cmppath,
  },

  ["L3MON4D3/LuaSnip"] = {
    override_options = overrides.luasnip,
  },

  ["NvChad/nvterm"] = { -- For more native terminal buffer experience
    override_options = overrides.nvterm,
  },

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
