-- -- autocommand that reloads neovim and installs/updates/removes plugins
-- -- when file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]])

local plugins = {
  ["nvim-lua/plenary.nvim"] = { module = "plenary" },

	["lewis6991/impatient.nvim"] = {},

	["wbthomason/packer.nvim"] = {
		cmd = require("core.lazy_load").packer_cmds,
		config = function()
			require("plugins")
		end,
	},

  -- ["bluz71/vim-nightfly-guicolors"] = {}
	-- use("szw/vim-maximizer") -- maximizes and restores current window
	-- use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
	-- use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)
	-- use("nvim-lualine/lualine.nvim")

	-- ["Nsindrets/diffview"] = {
	-- 	config = function()
	-- 		local present, diffview = pcall(require, "diffview")
	--
	-- 		if present then
	-- 			diffview.setup()
	-- 		end
	-- 	end,
	-- },

	["NvChad/extensions"] = { module = { "telescope", "nvchad" } },

	["NvChad/base46"] = {
		config = function()
			local ok, base46 = pcall(require, "base46")

			if ok then
				base46.load_theme()
			end
		end,
	},

	["NvChad/ui"] = {
		after = "base46",
		config = function()
			local present, nvchad_ui = pcall(require, "nvchad_ui")

			if present then
				nvchad_ui.setup()
			end
		end,
	},

	-- use("akinsho/toggleterm.nvim")
	["NvChad/nvterm"] = {
		module = "nvterm",
		config = function()
			require("plugins.configs.nvterm")
		end,
		setup = function()
			require("core.utils").load_mappings("nvterm")
		end,
	},

	-- use("nvim-tree/nvim-web-devicons")
	["kyazdani42/nvim-web-devicons"] = {
		after = "ui",
		module = "nvim-web-devicons",
		config = function()
			require("plugins.configs.others").devicons()
		end,
	},

	["lukas-reineke/indent-blankline.nvim"] = {
		opt = true,
		setup = function()
			require("core.lazy_load").on_file_open("indent-blankline.nvim")
			require("core.utils").load_mappings("blankline")
		end,
		config = function()
			require("plugins.configs.others").blankline()
		end,
	},

	["NvChad/nvim-colorizer.lua"] = {
		opt = true,
		setup = function()
			require("core.lazy_load").on_file_open("nvim-colorizer.lua")
		end,
		config = function()
			require("plugins.configs.others").colorizer()
		end,
	},

	["nvim-treesitter/nvim-treesitter"] = {
		module = "nvim-treesitter",
		setup = function()
			require("core.lazy_load").on_file_open("nvim-treesitter")
		end,
		cmd = require("core.lazy_load").treesitter_cmds,
		run = ":TSUpdate",
		config = function()
			require("plugins.configs.treesitter")
		end,
	},

	-- git stuff
	["lewis6991/gitsigns.nvim"] = {
		ft = "gitcommit",
		setup = function()
			require("core.lazy_load").gitsigns()
		end,
		config = function()
			require("plugins.configs.others").gitsigns()
		end,
	},

	-- lsp stuff
	-- use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig
	["williamboman/mason.nvim"] = {
		cmd = require("core.lazy_load").mason_cmds,
		config = function()
			require("plugins.configs.mason")
		end,
	},

	["neovim/nvim-lspconfig"] = {
		opt = true,
		setup = function()
			require("core.lazy_load").on_file_open("nvim-lspconfig")
		end,
		config = function()
			require("plugins.configs.lspconfig")
		end,
	},

	-- load luasnips + cmp related in insert mode only

	["rafamadriz/friendly-snippets"] = {
		module = { "cmp", "cmp_nvim_lsp" },
		event = "InsertEnter",
	},

	["hrsh7th/nvim-cmp"] = {
		after = "friendly-snippets",
		config = function()
			require("plugins.configs.cmp")
		end,
	},

	["L3MON4D3/LuaSnip"] = {
		wants = "friendly-snippets",
		after = "nvim-cmp",
		config = function()
			require("plugins.configs.others").luasnip()
		end,
	},

	["saadparwaiz1/cmp_luasnip"] = { after = "LuaSnip" },
	["hrsh7th/cmp-nvim-lua"] = { after = "cmp_luasnip" },
	["hrsh7th/cmp-nvim-lsp"] = { after = "cmp-nvim-lua" },
	["hrsh7th/cmp-buffer"] = { after = "cmp-nvim-lsp" },
	["hrsh7th/cmp-path"] = { after = "cmp-buffer" },
	-- use({ "glepnir/lspsaga.nvim", branch = "main" }) -- enhanced lsp uis
	-- use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
	-- use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

	-- -- formatting & linting
	-- use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
	-- use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls

	-- misc plugins
	["windwp/nvim-autopairs"] = {
		after = "nvim-cmp",
		config = function()
			require("plugins.configs.others").autopairs()
		end,
	},
	-- use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

	["goolord/alpha-nvim"] = {
		after = "base46",
		disable = true,
		config = function()
			require("plugins.configs.alpha")
		end,
	},

	["numToStr/Comment.nvim"] = {
		module = "Comment",
		keys = { "gc", "gb" },
		config = function()
			require("plugins.configs.others").comment()
		end,
		setup = function()
			require("core.utils").load_mappings("comment")
		end,
	},

	-- file managing , picker etc
	["kyazdani42/nvim-tree.lua"] = {
		ft = "alpha",
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		config = function()
			require("plugins.configs.nvimtree")
		end,
		setup = function()
			require("core.utils").load_mappings("nvimtree")
		end,
	},

	-- use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
	-- use({ "nvim-telescope/telescope-project.nvim" }) --
	-- use({ "nvim-telescope/telescope-file-browser.nvim" }) --
	-- use({ "cljoly/telescope-repo.nvim" }) --
	-- use({ "LinArcX/telescope-command-palette.nvim" }) --
	-- use({ "NvChad/base46" }) --
	-- use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" }) -- fuzzy finder
	["nvim-telescope/telescope.nvim"] = {
		cmd = "Telescope",
		config = function()
			require("plugins.configs.telescope")
		end,
		setup = function()
			require("core.utils").load_mappings("telescope")
		end,
	},

	-- Only load whichkey after all the gui
	["folke/which-key.nvim"] = {
		disable = true,
		module = "which-key",
		keys = { "<leader>", '"', "'", "`" },
		config = function()
			require("plugins.configs.whichkey")
		end,
		setup = function()
			require("core.utils").load_mappings("whichkey")
		end,
	},
}

-- Load all plugins
local present, packer = pcall(require, "packer")

if present then
	vim.cmd("packadd packer.nvim")

	-- Override with default plugins with user ones
	plugins = require("core.utils").merge_plugins(plugins)

	-- load packer init options
	local init_options = require("plugins.configs.others").packer_init()
	init_options = require("core.utils").load_override(init_options, "wbthomason/packer.nvim")

	packer.init(init_options)
	packer.startup({ plugins })
end
