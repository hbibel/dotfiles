local M = {}

M.init = function()
  vim.filetype.add({extension = { hip = "cuda" } })

  vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=never",
    },
    root_markers = { "CMakeLists.txt" },
  })
  vim.lsp.enable("clangd")
end

return M

