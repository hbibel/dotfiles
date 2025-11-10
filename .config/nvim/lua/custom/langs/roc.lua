local M = {}

M.init = function()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.roc" },
    command = "set filetype=roc",
  })

  -- add roc tree-sitter
  local parsers = require("nvim-treesitter.parsers").get_parser_configs()

  parsers.roc = {
    install_info = {
      url = "https://github.com/faldor20/tree-sitter-roc",
      files = { "src/parser.c", "src/scanner.c" },
    },
  }

  vim.lsp.config("roc", {
    cmd = { "roc_language_server" },
    filetypes = { "roc" },
    root_markers = { ".git" },
  })
  vim.lsp.enable("roc")
end

return M
