return {
  setup = function()
    local nvim_lint = require("lint")

    local python_linters = {}

    local mypy_cmd = require("custom.python").get_mypy_command()
    if mypy_cmd ~= nil then
      nvim_lint.linters.mypy.cmd = mypy_cmd[1]
      nvim_lint.linters.mypy.args = { unpack(mypy_cmd, 2) }

      table.insert(python_linters, "mypy")
    end

    --- Find a binary in the node_modules of any parent of the current buffer
    ---
    --- @param cmd string
    --- @return string | nil
    local function find_node_modules_binary(cmd)
      local node_modules_parent = vim.fs.root(0, { "node_modules" })
      while node_modules_parent ~= nil do
        local binary_path = node_modules_parent .. "/node_modules/.bin/" .. cmd
        if vim.uv.fs_stat(binary_path) then
          -- TODO difference between this and vim.fs.normalize?
          return vim.fn.fnamemodify(binary_path, ":p")
        end
        node_modules_parent = vim.fs.root(
          vim.fs.joinpath(node_modules_parent, ".."),
          { "node_modules" }
        )
      end

      return nil
    end

    local xo_bin = find_node_modules_binary("xo")
    if xo_bin then
      nvim_lint.linters.eslint.cmd = xo_bin
      nvim_lint.linters.eslint.args = {
        "--reporter",
        "json",
        "--stdin",
        "--stdin-filename",
        function() return vim.api.nvim_buf_get_name(0) end,
      }
    else
      local binary_name = "eslint"
      local eslint = find_node_modules_binary(binary_name)
      nvim_lint.linters.eslint.cmd = eslint or binary_name
    end

    nvim_lint.linters_by_ft = {
      python = python_linters,
      typescript = { "eslint", }
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
