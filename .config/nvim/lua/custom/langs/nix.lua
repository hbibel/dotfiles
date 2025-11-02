local M = {}

M.init = function()
  vim.lsp.config("nil_ls", {
    cmd = { "nil" },
    filetypes = { "nix" },
    root_markers = { ".venv", "pyproject.toml" },
  })
  vim.lsp.enable("nil_ls")
end

return M
