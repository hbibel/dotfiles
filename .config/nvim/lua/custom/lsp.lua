local M = {}

M.on_attach = function(_, bufnr)
  local keymaps = require("custom.keymaps")
  local scala = require("custom.scala")
  local python = require("custom.python")
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

  if file_type == "python" then
    keymaps.python(bufnr)
    python.attach_lsp()
  end
end

M.servers = function()
  local python = require("custom.python")
  return {
    gopls = {
      filetypes = { "go", "gomod", },
    },
    pylsp = {
      settings = python.pylsp_config(),
    },
    lua_ls = {},
    rust_analyzer = {},
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
    astro = {},
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

  -- mason_lspconfig.setup_handlers {
  --   function(server_name)
  --     local args = {
  --       capabilities = capabilities,
  --       on_attach = M.on_attach,
  --       settings = (servers[server_name] or {}).settings,
  --       filetypes = (servers[server_name] or {}).filetypes,
  --     }
  --     if servers[server_name] ~= nil and servers[server_name].cmd ~= nil then
  --       args.cmd = servers[server_name].cmd
  --     end
  --     require("lspconfig")[server_name].setup(args)
  --   end
  -- }
end

return M
