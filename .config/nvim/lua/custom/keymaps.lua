M = {}

-- Comment.nvim predefines
-- [normal mode] `gcc` - Toggles the current line using linewise comment
-- [normal mode] `gbc` - Toggles the current line using blockwise comment
-- [normal mode] `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
-- [normal mode] `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
-- [normal mode] `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
-- [normal mode] `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment
-- [visual mode] `gc` - Toggles the region using linewise comment
-- [visual mode] `gb` - Toggles the region using blockwise comment

M.basic = function()
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
  vim.keymap.set({ 'n', 'v' }, '<C-e>', '4<C-e>')
  vim.keymap.set({ 'n', 'v' }, '<C-y>', '4<C-y>')

  vim.keymap.set("n", "<leader>cp", ':let @+ = expand("%")<cr>', { desc = "Copy filename to clipboard " })

  -- Basic text editing
  vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
  vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
  vim.keymap.set("v", "H", "<gv")
  vim.keymap.set("v", "L", ">gv")

  -- Remap for dealing with word wrap
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- Diagnostic keymaps
  vim.keymap.set(
    'n', '[d',
    function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = 'Go to previous diagnostic message' }
  )
  vim.keymap.set(
    'n', ']d',
    function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = 'Go to next diagnostic message' }
  )
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

  vim.keymap.set('n', '<leader>get', require('grapple').tag, { desc = '[G]rappl[e] [T]ag' })
  vim.keymap.set('n', '<leader>geu', require('grapple').untag, { desc = '[G]rappl[e] [U]ntag' })
  -- easier navigation out of a terminal
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = 0 })
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { buffer = 0 })
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { buffer = 0 })
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { buffer = 0 })
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { buffer = 0 })
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], { buffer = 0 })

  vim.keymap.set("n", "<leader>xq", function() vim.cmd("cclose") end, { desc = "Close Quickfix Window" })
end

function M.gitsigns(bufnr)
  local gs = package.loaded.gitsigns

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map("n", "]c", function()
    if vim.wo.diff then return "]c" end
    vim.schedule(function() gs.next_hunk() end)
    return "<Ignore>"
  end, { expr = true })

  map("n", "[c", function()
    if vim.wo.diff then return "[c" end
    vim.schedule(function() gs.prev_hunk() end)
    return "<Ignore>"
  end, { expr = true })

  -- Actions
  map("n", "<leader>hs", gs.stage_hunk)
  map("n", "<leader>hr", gs.reset_hunk)
  map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end)
  map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end)
  map("n", "<leader>hS", gs.stage_buffer)
  map("n", "<leader>hu", gs.undo_stage_hunk)
  map("n", "<leader>hR", gs.reset_buffer)
  map("n", "<leader>hp", gs.preview_hunk)
  map("n", "<leader>hb", function() gs.blame_line { full = true } end)
  map("n", "<leader>tb", gs.toggle_current_line_blame)
  map("n", "<leader>hd", gs.diffthis)
  map("n", "<leader>hD", function() gs.diffthis("~") end)
  map("n", "<leader>td", gs.toggle_deleted)

  -- Text object
  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
end

return M
