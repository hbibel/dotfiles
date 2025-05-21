local M = {
  tools_checked = false,
}

---@return boolean
M.venv_in_project = function()
  return M.get_venv_dir() ~= nil
end

---@return string | nil
M.get_venv_dir = function()
  local utils = require("custom.utils")

  local venv_parent = utils.search_upwards(function(dir)
    return vim.fn.isdirectory(dir .. "/.venv") == 1
  end)
  if venv_parent ~= nil then
    return venv_parent .. "/.venv"
  end
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

M.pylsp_config = function()
  local venv_dir = M.get_venv_dir()
  if venv_dir ~= nil then
    -- Jedi does not like it if we use a relative path for an environment
    -- created with venv (no issues with Poetry virtual environments, wtf)
    venv_dir = vim.fn.getcwd() .. "/" .. venv_dir
  end

  return {
    -- see https://github.com/python-lsp/python-lsp-server/blob/eb61ccd97bbe9c58fbde6496a78015ee3c129146/CONFIGURATION.md
    pylsp = {
      plugins = {
        -- Using Ruff for linting and formatting, see python.lua
        autopep8 = {
          enabled = false,
        },
        pycodestyle = {
          enabled = false,
        },
        jedi = {
          environment = venv_dir,
        },
      },
    }
  }
end

M.init = function(on_attach)
  table.insert(require("dap").configurations.python,
    {
      name = "Pytest current file",
      type = "python",
      request = "launch",
      module = "pytest",
      args = { "${file}" },
      justMyCode = "false",
      -- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    }
  )

  local ruff_cmd
  if M.venv_in_project() then
    ruff_cmd = { M.get_venv_dir() .. "/bin/python", "-m", "ruff", "server" }
  else
    ruff_cmd = { "ruff-lsp" }
  end
  require("lspconfig").ruff.setup {
    cmd = ruff_cmd,
    on_attach = on_attach,
  }
end

M.attach_lsp = function()
  local venv_dir = M.get_venv_dir()

  if M.tools_checked == false then
    local tools = "Python setup"
    if M.get_mypy_command() ~= nil then
      tools = tools .. " ✅ type checking"
    else
      tools = tools .. " ❌ type checking"
    end
    if venv_dir ~= nil then
      tools = tools .. " ✅ venv discovered at " .. venv_dir
    else
      tools = tools .. " ❌ no venv discovered"
    end
    vim.print(tools)

    M.tools_checked = true
  end

  -- TODO also print whether linting and formatting are set up
end

return M
