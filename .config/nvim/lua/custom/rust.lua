local M = {}

-- TODO rust-tools is archived, migrate to https://github.com/mrcjkb/rustaceanvim

M.init = function()
  local rt = require("rust-tools")

  -- https://morezerosthanones.com/posts/start_debugging_in_neovim/

  local homedir = vim.env.HOME
  local codelldb_install_dir = homedir .. "/.local/share/nvim/mason/packages/codelldb"
  rt.setup({
    server = {
      on_attach = function(_, bufnr)
        vim.keymap.set(
          "n",
          "<C-space>",
          rt.hover_actions.hover_actions,
          { buffer = bufnr }
        )
        local km = require("custom.keymaps")
        km.lsp(bufnr)
      end,
      settings = {
        ["rust-analyzer"] = {
          check = {
            command = "clippy",
            extraArgs = { "--all", "--", "-W", "clippy::pedantic" },
          },
        },
      },

    },
    dap = {
      adapter = {
        type = "executable",
        command = codelldb_install_dir .. "/codelldb",
        name = "codelldb",
      },
    },
  })

  -- run:
  -- . $HOME/.local/share/nvim/mason/packages/codelldb/codelldb --port 13000
  require("dap").adapters.codelldb = {
    type = 'server',
    host = '127.0.0.1',
    port = 13000
  }

  require("dap").configurations.rust = {
    {
      name = "Debug",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
      sourceLanguages = { 'rust' },
    },
  }
end

return M
