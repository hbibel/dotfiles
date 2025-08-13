local M = {}

--Recursively search a directory predicate, iterating over its ancestors
--
---@param predicate fun(string): boolean
---@return string | nil
M.search_upwards = function(predicate)
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  if vim.fn.isdirectory(current_file) then
    current_dir = current_file
  else
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  while current_dir ~= "/" do
    if predicate(current_dir) then
      return current_dir
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end

  return nil
end

return M
