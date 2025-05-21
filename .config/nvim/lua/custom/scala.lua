local M = {}

M.file_types = { "scala", "sbt", "java" }

function M.init(lsp_on_attach)
  local metals_config = require("metals").bare_config()
  metals_config.init_options.statusBarProvider = "on"
  metals_config.on_attach = lsp_on_attach
  local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = function()
      require("metals").initialize_or_attach(metals_config)
    end,
    group = nvim_metals_group,
  })
end

-- Metals status indicator, e.g. "Indexing"
function M.metals_status()
  return vim.g["metals_status"] or ""
end

function M.attach_lsp(dap)
  -- Let metals show helpful messages
  vim.opt_global.shortmess:remove("F")

  require("metals").setup_dap()
  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run file",
      metals = {
        runType = "runOrTestFile",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Run with local environment",
      metals = {
        runType = "runOrTestFile",
        envFile = ".env.local",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Run or Test",
      metals = {
        runType = "runOrTestFile",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = {
        runType = "testTarget",
      },
    }
  }
end

M.plugins = {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim'
  }
}

return M
