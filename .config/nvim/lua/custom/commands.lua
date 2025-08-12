local function basic()
  -- Open help in vertical split
  -- There's also a fancy plugin, but I don't need the fanciness now
  -- https://github.com/anuvyklack/help-vsplit.nvim
  vim.cmd("command! -nargs=1 Hlp rightbelow vert help <args>")

  -- I can't type
  vim.cmd("command! -nargs=* W w <args>")
  vim.cmd("command! -nargs=* Wq wq <args>")

  -- Create a point in time to recover later, useful for small experiments
  -- within a file which I want to undo in one step
  vim.cmd("command! -nargs=0 Snap let snapshot=undotree().seq_last")
  vim.cmd("command! -nargs=0 Usnap exe 'undo ' . snapshot")
end

local function lsp(bufnr)
  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    require('conform').format()
  end, { desc = 'Format current buffer with LSP' })
end

return {
  basic = basic,
  lsp = lsp,
}
