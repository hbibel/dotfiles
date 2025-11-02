--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Sort order
-- 1. non-dot directories
-- 2. non-dot files
-- 3. dot files
-- 4. dot directories
vim.g.netrw_sort_sequence = "^[^\\.].*[\\/]$,*,^\\..*[^/]$,\\..*\\/$"

require("custom.plugins")
require("custom.vimconfigs")

local python = require("custom.python")
local keymaps = require("custom.keymaps")
local roc = require("custom.roc")
local bicep = require("custom.bicep")
local lua = require("custom.lua")
local rust = require("custom.rust")
local javascript = require("custom.javascript")

keymaps.basic()

require("custom.commands").basic()

python.init()
roc.init()
bicep.init()
lua.init()
rust.init()
javascript.init()
require("custom.langs.nix").init()

local group = vim.api.nvim_create_augroup("OverrideMelange", {})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "melange",
  callback = function() vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" }) end,
  group = group,
})
vim.opt.termguicolors = true
vim.cmd.colorscheme "melange"

-- import init_workspace.lua, if it exists
pcall(require, "init_workspace")

vim.opt_local.indentkeys:remove(":")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
