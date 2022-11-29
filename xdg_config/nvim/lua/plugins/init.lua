-- plugins/init.lua

local plugins = {

  ["nvim-lua/plenary.nvim"] = { module = "plenary" },

  ["lewis6991/impatient.nvim"] = {},

  ["jakelogemann/nvim-ide-plugin"] = {
    config = function()
      require "plugins.configs.nvimide"
    end,
  },

  ["wbthomason/packer.nvim"] = {
    cmd = require("core.lazy_load").packer_cmds, -- {{{
    config = function()
      require "plugins"
    end,
  }, -- }}}

  -- ["NvChad/extensions"] = { module = { "telescope", "nvchad" } },

  ["NvChad/base46"] = {
    config = function() -- {{{
      local ok, base46 = pcall(require, "base46")

      if ok then
        base46.load_theme()
      end
    end,
  }, -- }}}

  -- ["NvChad/ui"] = {
  --   after = "base46", -- {{{
  --   config = function()
  --     local present, nvchad_ui = pcall(require, "nvchad_ui")
  --
  --     if present then
  --       nvchad_ui.setup()
  --     end
  --   end,
  --   --  override_options = {
  --   --    tabufline = {
  --   --      lazyload = false, -- to show tabufline by default
  --   --      overriden_modules = function()
  --   --        return require "custom.configs.xyz"
  --   --      end,
  --   --    },
  --   --  },
  -- }, -- }}}

  ["NvChad/nvterm"] = { -- For more native terminal buffer experience
    module = "nvterm", -- {{{
    config = function()
      require "plugins.configs.nvterm"
    end,
    setup = function()
      require("core.utils").load_mappings "nvterm"
    end,
  }, -- }}}

  ["kyazdani42/nvim-web-devicons"] = {
    -- after = "ui", -- {{{
    module = "nvim-web-devicons",
    config = function()
      require "plugins.configs.devicons"
    end,
  }, -- }}}

  ["lukas-reineke/indent-blankline.nvim"] = {
    opt = true, -- {{{
    setup = function()
      require("core.lazy_load").on_file_open "indent-blankline.nvim"
      require("core.utils").load_mappings "blankline"
    end,
    config = function()
      require "plugins.configs.blankline"
    end,
  }, -- }}}

  -- ["NvChad/nvim-colorizer.lua"] = {
  --   opt = true, -- {{{
  --   setup = function()
  --     require("core.lazy_load").on_file_open "nvim-colorizer.lua"
  --   end,
  --   config = function()
  --     require "plugins.configs.colorizer"
  --   end,
  -- }, -- }}}

  ["nvim-treesitter/nvim-treesitter"] = { -- For syntax highlighting
    module = "nvim-treesitter", -- {{{
    setup = function()
      require("core.lazy_load").on_file_open "nvim-treesitter"
    end,
    cmd = require("core.lazy_load").treesitter_cmds,
    run = ":TSUpdate",
    config = function()
      require "plugins.configs.treesitter"
    end,
  }, -- }}}

  -- git stuff
  ["lewis6991/gitsigns.nvim"] = {
    ft = "gitcommit", -- {{{
    setup = function()
      require("core.lazy_load").gitsigns()
    end,
    config = function()
      require "plugins.configs.gitsigns"
    end,
  }, -- }}}

  -- lsp stuff
  ["williamboman/mason.nvim"] = {
    cmd = require("core.lazy_load").mason_cmds, -- {{{
    config = function()
      require "plugins.configs.mason"
    end,
  }, -- }}}

  -- use("jose-elias-alvarez/typescript.nvim")
  ["jose-elias-alvarez/typescript.nvim"] = { --[[ after = "LuaSnip" ]]
  }, -- additional functionality for typescript server (e.g. rename file & update imports)
  ["jose-elias-alvarez/nvim-lsp-ts-utils"] = {},
  ["williamboman/nvim-lsp-installer"] = {},

  ["neovim/nvim-lspconfig"] = { -- Language Server Protocol / for syntax errors
    opt = true, -- {{{
    setup = function()
      require("core.lazy_load").on_file_open "nvim-lspconfig"
    end,
    config = function()
      require "plugins.configs.lspconfig"
    end,
  }, -- }}}

  ["glepnir/lspsaga.nvim"] = { -- enhanced lsp uis
    -- after = "nvim-lspconfig", -- {{{
    config = function()
      require "plugins.configs.lspsaga"
    end,
  }, -- }}}

  ["jose-elias-alvarez/null-ls.nvim"] = { -- code formatting, linting etc
    after = "nvim-lspconfig", -- {{{
    config = function()
      require "plugins.configs.null-ls"
    end,
  }, -- }}}

  -- load luasnips + cmp related in insert mode only
  ["rafamadriz/friendly-snippets"] = {
    module = { "cmp", "cmp_nvim_lsp" }, -- {{{
    event = "InsertEnter",
  }, -- }}}

  ["hrsh7th/nvim-cmp"] = {
    after = "friendly-snippets", -- {{{
    config = function()
      require "plugins.configs.cmp"
    end,
  }, -- }}}

  ["L3MON4D3/LuaSnip"] = {
    wants = "friendly-snippets", -- {{{
    after = "nvim-cmp",
    config = function()
      require "plugins.configs.luasnip"
    end,
  }, -- }}}

  -- Sources
  ["saadparwaiz1/cmp_luasnip"] = { after = "LuaSnip" },
  ["hrsh7th/cmp-nvim-lua"] = { after = "cmp_luasnip" }, -- When writing lua, it has special nvim knowlede and does good completions
  ["hrsh7th/cmp-nvim-lsp"] = { after = "cmp-nvim-lua" }, -- To get super easy auto imports on completes
  ["hrsh7th/cmp-buffer"] = { after = "cmp-nvim-lsp" }, -- Completes words from the current buffer that your in
  ["hrsh7th/cmp-path"] = { after = "cmp-buffer" }, -- Completes files

  -- misc plugins
  ["windwp/nvim-autopairs"] = {
    after = "nvim-cmp", -- {{{
    config = function()
      require "plugins.configs.autopairs"
    end,
  }, -- }}}

  -- TODO: Use vim-startify instead? https://github.com/mhinz/vim-startify
  ["goolord/alpha-nvim"] = { -- Neovim start dashboard view
    after = "base46", -- {{{
    disable = false,
    config = function()
      require "plugins.configs.alpha"
    end,
  }, -- }}}

  ["numToStr/Comment.nvim"] = {
    module = "Comment", -- {{{
    keys = { "gc", "gb" },
    basic = true, -- includes 'gcc', 'gcb', 'gc[count]{motion}', 'gc[count]{motion}'
    extra = true, -- includes 'gco', 'gcO', 'gcA'
    extended = true, -- includes 'g>', 'g<', 'g>[count]{motion}' and 'gc<[count]{motion}'
    config = function()
      require "plugins.configs.comment"
    end,
    setup = function()
      require("core.utils").load_mappings "comment"
    end,
  }, -- }}}

  -- file managing , picker etc
  ["kyazdani42/nvim-tree.lua"] = { -- Left-side file explorer
    ft = "alpha", -- {{{
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require "plugins.configs.nvimtree"
    end,
    setup = function()
      require("core.utils").load_mappings "nvimtree"
    end,
  }, -- }}}

  ["nvim-telescope/telescope.nvim"] = {
    cmd = "Telescope", -- {{{
    config = function()
      require "plugins.configs.telescope"
    end,
    setup = function()
      require("core.utils").load_mappings "telescope"
    end,
  }, -- }}}

  -- Only load whichkey after all the gui
  ["folke/which-key.nvim"] = { -- Keymappings cheatsheet helper
    disable = false, -- {{{
    module = "which-key",
    keys = { "<leader>", '"', "'", "`" },
    config = function()
      require "plugins.configs.whichkey"
    end,
    setup = function()
      require("core.utils").load_mappings "whichkey"
    end,
  }, -- }}}
}

-- Some more plugins to setup and configure
-- ["Nsindrets/diffview"] = {{{{
--   config = function()
--     local present, diffview = pcall(require, "diffview")
--
--     if present then
--       diffview.setup()
--     end
--   end,
-- },

-- ["bluz71/vim-nightfly-guicolors"] = {}
-- use("szw/vim-maximizer") -- maximizes and restores current window
-- use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
-- use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)
-- use("nvim-lualine/lualine.nvim")

-- use({ "glepnir/lspsaga.nvim", branch = "main" }) -- enhanced lsp uis
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
-- ["LinArcX/telescope-command-palette.nvim"] = {},}}}

-- Load all plugins
local present, packer = pcall(require, "packer") -- {{{

if present then
  vim.cmd "packadd packer.nvim"

  -- Override with default plugins with user ones
  plugins = require("core.utils").merge_plugins(plugins)

  -- load packer init options
  local init_options = {
    auto_clean = true,
    compile_on_sync = true,
    git = { clone_timeout = 6000 },
    display = {
      working_sym = "ﲊ",
      error_sym = "✗ ",
      done_sym = " ",
      removed_sym = " ",
      moved_sym = "",
      open_fn = function()
        return require("packer.util").float { border = "single" }
      end,
    },
  }
  init_options = require("core.utils").load_override(init_options, "wbthomason/packer.nvim")

  packer.init(init_options)
  packer.startup { plugins }
end -- }}}
