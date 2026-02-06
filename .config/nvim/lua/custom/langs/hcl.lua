local M = {}

M.init = function()
  -- vim.filetype.add({
  --   extension = {
  --     tf = "terraform",
  --     tofu = "terraform",
  --   },
  -- })
  vim.lsp.config("tofu-ls", {
    cmd = {
      "tofu-ls", "serve",
    },
    filetypes = { "terraform" },
    root_markers = { ".terraform", ".git" },
    -- TODO make this support both terraform and tofu depending on the project
    -- or use the tofu-ls for tofu projects and terraform-ls on terraform
    -- projects
  })
  vim.lsp.enable("tofu-ls")
end

return M
