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
    filetypes = { "bicep", "bicep-params" },
    get_language_id = function(bufnr, filetype)
      -- Stupid workaround: I couldn't figure out why the BufEnter autocmd does
      -- not set the filetype before the language ID is passed to the LSP
      -- server; without this, if I open a .bicep file and then a .bicepparam
      -- files, the language server will think the .bicepparam file is a .bicep
      -- file
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:find("bicepparam$") ~= nil then
        return "bicep-params"
      end
      return "bicep"
    end
  })
  vim.lsp.enable("bicep")
end

return M
