local M = {}

M.init = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.bicepparam" },
    command = "set filetype=bicep-params",
  })

  vim.lsp.config("bicep", {
    cmd = {
      "dotnet",
      vim.fn.expand("$HOME/software/bicep_lsp/Bicep.LangServer.dll")
    },
    filetypes = { "bicep", "bicep-params" }
  })
  vim.lsp.enable("bicep")
end

return M
