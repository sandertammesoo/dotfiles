local load_override = R("core.utils").load_override

-- default components
local explorer = require "ide.components.explorer"
local outline = require "ide.components.outline"
local callhierarchy = require "ide.components.callhierarchy"
local timeline = require "ide.components.timeline"
local terminal = require "ide.components.terminal"
local terminalbrowser = require "ide.components.terminal.terminalbrowser"
local changes = require "ide.components.changes"
local commits = require "ide.components.commits"
local branches = require "ide.components.branches"
local bookmarks = require "ide.components.bookmarks"

local present, nvim_ide = pcall(require, "ide")

if not present then
  return
end

local options = {
  -- the global icon set to use.
  -- values: "nerd", "codicon", "default"
  icon_set = "nerd",
  -- place Component config overrides here.
  -- they key to this table must be the Component's unique name and the value
  -- is a table which overrides any default config values.
  components = {
    -- Explorer = {
    --     keymaps = {
    --         expand = "x",
    --     }
    -- }
    Bookmarks = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        jump = "<CR>",
        jump_tab = "t",
        hide = "<C-[>",
        close = "X",
        maximize = "+",
        minimize = "-",
      },
    },
    Branches = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        jump = "<CR>",
        create_branch = "c",
        refresh = "r",
        hide = "<C-[>",
        close = "X",
        details = "d",
        maximize = "+",
        minimize = "-",
      },
    },
    CallHierarchy = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        jump = "<CR>",
        jump_split = "s",
        jump_vsplit = "v",
        jump_tab = "t",
        hide = "<C-[>",
        close = "X",
        next_reference = "n",
        maximize = "+",
        minimize = "-",
      },
    },
    Changes = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        restore = "r",
        add = "s",
        amend = "a",
        commit = "c",
        jump = "<CR>",
        jump_tab = "t",
        hide = "<C-[>",
        close = "X",
        maximize = "+",
        minimize = "-",
      },
    },
    Commits = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        checkout = "c",
        jump = "<CR>",
        jump_split = "s",
        jump_vsplit = "v",
        jump_tab = "t",
        refresh = "r",
        hide = "<C-[>",
        close = "X",
        details = "d",
        maximize = "+",
        minimize = "-",
      },
    },
    Explorer = {
      list_directories_first = true,
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        edit = "<CR>",
        edit_split = "s",
        edit_vsplit = "v",
        edit_tab = "t",
        hide = "<C-[>",
        close = "X",
        new_file = "n",
        delete_file = "D",
        new_dir = "d",
        rename_file = "r",
        move_file = "m",
        copy_file = "p",
        select_file = "<Space>",
        deselect_file = "<Space><Space>",
        change_dir = "cd",
        up_dir = "..",
        file_details = "i",
        toggle_exec_perm = "*",
        maximize = "+",
        minimize = "-",
      },
    },
    Outline = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        jump = "<CR>",
        jump_split = "s",
        jump_vsplit = "v",
        jump_tab = "t",
        hide = "<C-[>",
        close = "X",
        maximize = "+",
        minimize = "-",
      },
    },
    TerminalBrowser = {
      disabled_keymaps = false,
      keymaps = {
        new = "n",
        jump = "<CR>",
        hide = "<C-[>",
        delete = "D",
        rename = "r",
        maximize = "+",
        minimize = "-",
      },
    },
    Timeline = {
      disabled_keymaps = false,
      keymaps = {
        expand = "zo",
        collapse = "zc",
        collapse_all = "zM",
        jump = "<CR>",
        jump_split = "s",
        jump_vsplit = "v",
        jump_tab = "t",
        hide = "<C-[>",
        close = "X",
        details = "d",
        maximize = "+",
        minimize = "-",
      },
    },
  },
  -- default panel groups to display on left and right.
  panels = {
    left = "explorer",
    right = "git",
  },
  -- panels defined by groups of components, user is free to redefine these
  -- or add more.
  panel_groups = {
    explorer = { outline.Name, explorer.Name, bookmarks.Name, callhierarchy.Name, terminalbrowser.Name },
    terminal = { terminal.Name },
    git = { changes.Name, commits.Name, timeline.Name, branches.Name },
  },
}
options = load_override(options, "jakelogemann/nvim-ide-plugin")
nvim_ide.setup(options)
