--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Sort order
-- 1. non-dot directories
-- 2. non-dot files
-- 3. dot files
-- 4. dot directories
vim.g.netrw_sort_sequence = "^[^\\.].*[\\/]$,*,^\\..*[^/]$,\\..*\\/$"

require('custom.plugins')
require('custom.vimconfigs')

local scala = require('custom.scala')
local rust = require('custom.rust')
local python = require('custom.python')
local keymaps = require('custom.keymaps')
local helm = require("custom.helm")
local roc = require("custom.roc")
keymaps.basic()

require('custom.commands').basic()

local lsp = require('custom.lsp')
lsp.setup()
-- Scala (Metals) does some extra stuff to normal LSPs
scala.init(lsp.on_attach)
rust.init()
python.init(lsp.on_attach)
helm.init()
roc.init()

local group = vim.api.nvim_create_augroup('OverrideMelange', {})
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'melange',
  callback = function() vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' }) end,
  group = group,
})
vim.opt.termguicolors = true
vim.cmd.colorscheme "melange"

-- avante.nvim recommends this:
vim.opt.laststatus = 3

-- import init_workspace.lua, if it exists
pcall(require, 'init_workspace')

vim.opt_local.indentkeys:remove(":")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
