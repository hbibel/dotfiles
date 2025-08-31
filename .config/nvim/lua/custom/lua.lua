local M = {}

M.init = function()
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        diagnostics = {
          globals = { "vim" } }
      }
    }
  })
  vim.lsp.enable("lua_ls")
end

return M
