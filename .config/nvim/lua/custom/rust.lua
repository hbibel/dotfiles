local M = {}

M.init = function()
  -- more fancy features: https://github.com/mrcjkb/rustaceanvim
  vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    -- Prefer Cargo.lock, because in projects with multiple workspaces there
    -- are multiple Cargo.toml files
    root_markers = { "Cargo.lock", "Cargo.toml" },
    settings = {
      check = {
        command = "clippy",
        extraArgs = { "--all", "--", "-W", "clippy::pedantic" },
      }
    }
  })
  vim.lsp.enable("rust_analyzer")
end

return M
