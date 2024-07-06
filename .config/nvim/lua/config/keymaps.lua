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

-- add new line
map("n", "<CR>", "o<Esc>")
map("n", "<S-CR>", "O<Esc>")

-- splits
map("n", "<LocalLeader>-", "<cmd>split<CR>")
map("n", "<LocalLeader>=", "<cmd>vsplit<CR>")

-- switch splits
map("n", "<LocalLeader>h", "<C-W>H")
map("n", "<LocalLeader>j", "<C-W>J")
map("n", "<LocalLeader>k", "<C-W>K")
map("n", "<LocalLeader>l", "<C-W>L")

-- resize splits
map("n", "<LocalLeader>H", "<C-W><")
map("n", "<LocalLeader>J", "<C-W>+")
map("n", "<LocalLeader>K", "<C-W>-")
map("n", "<LocalLeader>L", "<C-W>>")

-- yanking
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
