local load_override = R("core.utils").load_override

local present1, autopairs = pcall(require, "nvim-autopairs")
local present2, cmp = pcall(require, "cmp")

if not (present1 and present2) then
  return
end

local options = {
  fast_wrap = {},
  disable_filetype = { "TelescopePrompt", "vim" },
  -- check_ts = true, -- enable treesitter
  -- ts_config = {
  -- 	lua = { "string" }, -- don't add pairs in lua string treesitter nodes
  -- 	javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
  -- 	java = false, -- don't check treesitter on java
  --  }
}

options = load_override(options, "windwp/nvim-autopairs")
autopairs.setup(options)

local cmp_autopairs = require "nvim-autopairs.completion.cmp"
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
