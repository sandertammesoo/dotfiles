local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end

require("base46").load_highlight "treesitter"

local options = {
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

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = {
    enable = true,
  },
}

-- check for any override
options = require("core.utils").load_override(options, "nvim-treesitter/nvim-treesitter")

treesitter.setup(options)
