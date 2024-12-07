-- In ./lua/config/lazy.lua
require("config.lazy")

vim.opt.shiftwidth = 4

-- See `:h nvim_create_autocmd()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  -- See `:h nvim_create_augroup()`
  group = vim.api.nvim_create_augroup('highlight-yank-yo', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
