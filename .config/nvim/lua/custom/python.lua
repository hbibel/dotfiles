local M = {
  tools_checked = false,
}

M.init = function()
  local root_dir
  if vim.fs.root(0, ".venv") ~= nil then
    root_dir = vim.fs.root(0, ".venv")
  else
    root_dir = vim.fn.getcwd()
  end

  local venv_dir = M.get_venv_dir()

  --   table.insert(require("dap").configurations.python,
  --     {
  --       name = "Pytest current file",
  --       type = "python",
  --       request = "launch",
  --       module = "pytest",
  --       args = { "${file}" },
  --       justMyCode = "false",
  --       -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
  --     }
  --   )

  M._register_lsps()

  M._print_tools_status(venv_dir)
end

---@return boolean
M.venv_in_project = function()
  return M.get_venv_dir() ~= nil
end

---@return string | nil
M.get_venv_dir = function()
  local parent = vim.fs.root(0, ".venv")
  if parent == nil then
    return nil
  elseif not vim.fn.isdirectory(parent .. "/.venv") then
    vim.notify("Warning: " .. parent .. "/.venv exists but is not a directory")
    return nil
  else
    return parent .. "/.venv"
  end
end

M._register_lsps = function()
  local venv_dir = M.get_venv_dir()

  vim.lsp.config("zuban", {
    cmd = { "zuban", "server" },
    cmd_env = {
      VIRTUAL_ENV = venv_dir,
    },
    filetypes = { "python" },
    -- pyproject toml files can be in subdirectories for projects with uv
    -- workspaces, so .venv is the better root marker
    root_markers = { ".venv", "pyproject.toml" },
  })
  vim.lsp.enable("zuban")

  vim.lsp.config("ruff", {
    cmd = { M._ruff_path(venv_dir), "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml" },
  })
  vim.lsp.enable("ruff")
end

---@return string[] | nil
M.get_mypy_command = function()
  local venv_dir = M.get_venv_dir()
  if venv_dir ~= nil then
    local mypy_path = venv_dir .. "/bin/mypy"
    if vim.fn.filereadable(mypy_path) == 1 then
      -- args copied from
      -- https://github.com/mfussenegger/nvim-lint/blob/master/lua/lint/linters/mypy.lua
      -- but with the Python executable path fixed. If mypy breaks, check if
      -- something has changed with respect to the arguments
      return {
        mypy_path,
        "--show-column-numbers",
        "--show-error-end",
        "--hide-error-context",
        "--no-color-output",
        "--no-error-summary",
        "--no-pretty",
        "--python-executable",
        venv_dir .. "/bin/python",
      }
    end
  end

  return nil
end


M._ruff_path = function(venv_dir)
  if venv_dir == nil then
    return nil
  else
    return venv_dir .. "/bin/ruff"
  end
end

M._print_tools_status = function(venv_dir)
  if M.tools_checked == false then
    local tools = "Python setup"
    if M.get_mypy_command() ~= nil then
      tools = tools .. " ✅ type checking"
    else
      tools = tools .. " ❌ type checking"
    end
    if M._ruff_path(venv_dir) ~= nil then
      tools = tools .. " ✅ linting (ruff)"
    else
      tools = tools .. " ❌ linting"
    end
    if venv_dir ~= nil then
      tools = tools .. " ✅ venv discovered at " .. venv_dir
    else
      tools = tools .. " ❌ no venv discovered"
    end

    vim.notify(tools)

    M.tools_checked = true
  end

  -- TODO also print whether formatting is set up
end

return M
