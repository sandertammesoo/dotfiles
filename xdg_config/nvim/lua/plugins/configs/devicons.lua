-- local load_override = R("core.utils").load_override

local present, devicons = pcall(require, "nvim-web-devicons")

if present then
  require("base46").load_highlight "devicons"

  local options = { --[[ override = require("nvchad_ui.icons").devicons ]]
  }
  options = require("core.utils").load_override(options, "kyazdani42/nvim-web-devicons")

  devicons.setup(options)
end
