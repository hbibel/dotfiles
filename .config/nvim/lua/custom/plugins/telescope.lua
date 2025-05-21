local setup = function()
  require("telescope").setup {
    defaults = {
      mappings = {
        i = {
          ["<C-u>"] = false,
          ["<C-d>"] = false,
        },
      },
      file_ignore_patterns = { "node_modules", "target", ".git/" },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      },
    },
  }

  pcall(require("telescope").load_extension, "fzf")
end

return {
  setup = setup,
}
