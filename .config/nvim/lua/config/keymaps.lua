-- make all keymaps silent by default
local map = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  return map(mode, lhs, rhs, opts)
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- reload config
map("n", "<Leader>r", "<cmd>source<CR>")
