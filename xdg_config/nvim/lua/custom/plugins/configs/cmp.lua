local present, cmp = pcall(require, "cmp")

if not present then
  return
end

local options = {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(_, vim_item)
      local icons = require("nvchad_ui.icons").lspkind
      vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
      return vim_item
    end,
  },
  mapping = {
    -- ["<C-k>"] = cmp.mapping.select_prev_item(),
    -- ["<C-j>"] = cmp.mapping.select_next_item(),
    -- ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
    -- ["<C-g>"] = cmp.mapping.complete(),
    -- ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    },
  },
  sources = {
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
    {
      name = "buffer",
      keyword_length = 5,
      -- max_item_count  = 3
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

-- check for any override
options = require("core.utils").load_override(options, "hrsh7th/nvim-cmp")

cmp.setup(options)

-- nvim-cmp highlighting groups
-- local _, _, Group, g, s = require("tjdevries/colorbuddy").setup()
--
-- Group.new("CmpItemAbbr", g.Comment)
-- Group.new("CmpItemAbbrDeprecated", g.Error)
-- Group.new("CmpItemAbbrMatchFuzzy", g.CmpItemAbbr.fg:dark(), nil, s.italic)
-- Group.new("CmpItemKind", g.Special)
-- Group.new("CmpItemMenu", g.NonText)
