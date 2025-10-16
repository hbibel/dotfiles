local M = {
  tools_checked = false,
}

M.init = function()
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

  M._add_snippets()

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


--- Add an import, if it is not present yet
--- @param package string
--- @param item string
local function _add_import_cb(package, item)
  return function()
    if vim.treesitter.get_node() == nil then
      return
    end

    -- "from .. import .." statement
    local myquery = vim.treesitter.query.parse("python", "((import_from_statement) @node)")

    local root_node = vim.treesitter.get_node():root()
    local existing_import = nil
    for _, node in myquery:iter_captures(root_node, 0) do
      -- node is a single import statement
      local children = node:named_children()
      -- first named child is the "dotted_import", e.g. "os.path" or "dataclasses"
      local imported_module = vim.treesitter.get_node_text(children[1], 0)
      if imported_module == package then
        local imported_members = node:field('name')
        local last_end
        for _, m in pairs(imported_members) do
          last_row, last_col, _ = m:end_()
          if vim.treesitter.get_node_text(m, 0) == item then
            -- Found the requested import
            return
          end
        end

        -- We are importing from the requested package, but not the item we want
        vim.api.nvim_buf_set_text(
          0, last_row, last_col, last_row, last_col,
          { ", " .. item }
        )
        return
      end
    end

    -- add import to top of the file
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "from " .. package .. " import " .. item })
  end
end

M._add_snippets = function()
  local ls = require("luasnip")
  local events = require("luasnip.util.events")

  ls.add_snippets("python", {
    ls.snippet("dataclassfrozen", {
      ls.text_node({ "@dataclass(frozen=True)", "class " }),
      ls.insert_node(1),
      ls.text_node({ ":", "    " }),
      ls.insert_node(2),
    }, {
      callbacks = {
        [-1] = {
          [events.enter] = _add_import_cb("dataclasses", "dataclass")
        },
      },
    })
  })
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
