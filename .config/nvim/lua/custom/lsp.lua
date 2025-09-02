local M = {}

M.on_attach = function(_, bufnr)
  local keymaps = require("custom.keymaps")
  local scala = require("custom.scala")
  local dap = require("dap")
  local commands = require("custom.commands")

  keymaps.lsp(bufnr)

  commands.lsp(bufnr)

  local file_type = vim.bo[bufnr].filetype

  for _, ft in ipairs(scala.file_types) do
    if ft == file_type then
      scala.attach_lsp(dap)
      keymaps.scala(bufnr)
    end
  end
end

M.servers = function()
  return {
    gopls = {
      filetypes = { "go", "gomod", },
    },
    ts_ls = {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "html",
      }
    },
    marksman = {},
    yamlls = {},
    helm_ls = {
      settings = {
        yamlls = {
          path = "yaml-language-server",
        }
      }
    },
    ruff = {},
  }
end

M.setup = function()
  require("neodev").setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  require("mason").setup()

  local servers = M.servers()

  -- Ensure the servers above are installed
  local mason_lspconfig = require("mason-lspconfig")
  mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
  }

  -- Note: For historic reasons I'm using mason_lspconfig for most language
  -- servers. I'm planning to migrate everything to the builtin lspconfig, and
  -- install servers either globally or per project.
  local lspconfig = require("lspconfig")
  lspconfig.nil_ls.setup({
    settings = {

      -- Nix
      ['nil'] = {
        formatting = {
          command = { "nixfmt" },
        },
      },

    },
  })

  -- more fancy features: https://github.com/mrcjkb/rustaceanvim
  lspconfig.rust_analyzer.setup({
    on_attach = M.on_attach,
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
          extraArgs = { "--all", "--", "-W", "clippy::pedantic" },
        },
      },
    },
  })
end

return M
