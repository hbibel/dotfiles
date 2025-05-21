local scala = require("custom.scala")
local keymaps = require("custom.keymaps")

local snacks = require("custom.plugins.snacks")

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('custom.plugins.dap')

return require('lazy').setup({
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
      'folke/neodev.nvim',
    },
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require("custom.plugins.cmp").setup()
    end,
  },

  { 'folke/which-key.nvim',  opts = {} },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = keymaps.gitsigns,
    },

  },

  { "catppuccin/nvim",       name = "catppuccin", priority = 1000 },
  { "rose-pine/neovim",      name = "rose-pine",  priority = 1000 },
  { "folke/tokyonight.nvim", name = "tokyonight", lazy = false,   priority = 1000 },
  { "savq/melange-nvim" },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = true,
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename", scala.metals_status },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
    config = function()
      require('ibl').setup({
        indent = { char = '┊' },
      })
    end,
  },

  { 'numToStr/Comment.nvim',     opts = {} },

  {
    "folke/snacks.nvim",
    opts = snacks.opts,
    keys = snacks.keys,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require('custom.plugins.treesitter').setup()
    end,
  },
  { "nvim-treesitter/playground" },

  { "mfussenegger/nvim-dap" },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("dap-python").setup("~/software/debugpy/bin/python")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function() require("dapui").setup() end
  },

  {
    "cbochs/grapple.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  { 'rmagatti/goto-preview',   opts = {} },

  {
    'stevearc/conform.nvim',
    opts = {},
    config = require('custom.plugins.conform').setup,
  },

  {
    "mfussenegger/nvim-lint",
    opts = {},
    config = require("custom.plugins.nvim-lint").setup,
  },

  scala.plugins,

  { 'simrat39/rust-tools.nvim' },

  -- looks nicer than vim.opt.colorcolumn = "80"
  {
    "lukas-reineke/virt-column.nvim",
    opts = {
      virtcolumn = '80',
    }
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = "*",
    opts = {
      windows = {
        width = 50,
        edit = {
          start_insert = false,
        },
        ask = {
          start_insert = false,
        }
      },
      behaviour = {
        auto_suggestions = false,
      },
      system_prompt = "Don't ever write code comments, unless I explicitly tell you so.",
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}, {})
