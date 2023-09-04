vim.g.maplocalleader = ','
vim.wo.relativenumber = true
vim.wo.wrap = false

-- https://neovim.io/doc/user/lua-guide.html#lua-guide-mappings
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'n', 'nzz')

-- https://vi.stackexchange.com/a/18081
-- https://www.reddit.com/r/neovim/comments/yg2d9v/how_do_i_exit_the_terminal_mode/
vim.keymap.set('i', 'kj', '<esc>')
vim.keymap.set('v', 'kj', '<esc>')
vim.keymap.set('t', 'kj', [[<C-\><C-n>]])
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]])
vim.opt.timeoutlen = 200

-- https://www.youtube.com/watch?v=puWgHa7k3SY
vim.keymap.set('n', '<leader>ri', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = 'Diagnostics goto next' })
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = 'Diagnostics goto prev' })
vim.keymap.set('n', '<leader>dl', '<cmd>Telescope diagnostics<cr>', { desc = 'Diagnostics list' })
vim.keymap.set('n', '<leader>fi', '<cmd>Telescope file_browser<cr>', { desc = 'Browse files' })
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>', { desc = 'List LSP references' })
vim.keymap.set('n', '<leader>co', '<cmd>Telescope command_history<cr>', { desc = 'Command history' })
vim.keymap.set('n', '<leader>ci', '<cmd>Telescope commands<cr>', { desc = 'Show all commands' })

-- https://neovim.io/doc/user/syntax.html#guibg
-- https://neovim.io/doc/user/lua-guide.html#lua-guide-vimscript
-- https://stackoverflow.com/questions/3074068/how-to-change-the-color-of-the-selected-code-vim-scheme
-- vim.cmd("highlight Visual guibg=#322f46")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#denols
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- https://neovim.io/doc/user/lua-guide.html#lua-guide-options
-- https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 0
