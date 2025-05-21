local M = {}

M.is_helm = function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  return string.find(buf_path, "/templates/") ~= nil
end

M.init = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "yaml" },
    callback = function()
      if M.is_helm() then
        vim.api.nvim_command("set filetype=helm")
      end
    end,
  })
end

return M
