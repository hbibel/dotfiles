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
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
  vim.keymap.set('n', '|', '<cmd>Neotree reveal<cr>', { desc = 'Reveal current file in Neotree' })

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

function M.lsp(bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- DAP
  nmap('<leader>xo', require('dap').repl.close, '[Close] [O]utput')
  nmap('<leader>oo', require('dap').repl.open, '[Open] [O]utput')
  nmap("<F5>", require("dap").continue)
  nmap("<leader><F5>", require("dap").terminate)
  nmap("<F10>", require("dap").close)
  nmap("<F4>", require("dap").toggle_breakpoint)
  nmap("<F6>", require("dap").step_over)
  nmap("<F7>", require("dap").step_into)
  nmap("<F8>", require("dap").step_out)
  vim.keymap.set({ 'n', 'v' }, "<F2>", require('dap.ui.widgets').hover)
  vim.keymap.set({ 'n', 'v' }, "<F3>", require('dap.ui.widgets').preview)
  nmap("<F9>", require("dapui").toggle)
  -- Without dap-ui:
  -- nmap("<F9>", require("dap").repl.open)

  -- LSP aware code editing
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap("gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", '[G]oto [P]review [D]efinition')
  nmap("gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", '[G]oto [P]review [T]ype definition')
  nmap("gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", '[G]oto [P]review [I]mplementation')
  nmap("gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", '[G]oto [P]review [R]eferences')
  nmap("<leader>xp", "<cmd>lua require('goto-preview').close_all_win()<CR>", 'Close [P]review windows')

  -- Misc
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  nmap('<C-l>', vim.lsp.codelens.run, '[E]xecute [L]ens action')
end

function M.scala(bufnr)
  -- require('telescope.builtin').lsp_references doesn't work in Metals
  -- unfortunately
  vim.keymap.set('n', 'gr', vim.lsp.buf.references,
    { buffer = bufnr, desc = '[G]oto [R]eferences' })
end

return M
