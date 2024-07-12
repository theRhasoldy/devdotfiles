local utils = require("config.utils")
local map = utils.map

-- make all keymaps silent by default
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- reload config
map("n", "<leader>r", "<cmd>source<CR>")

-- add new line
map("n", "<cr>", "o<Esc>")
map("n", "<S-cr>", "O<Esc>")

-- splits
map("n", "<LocalLeader>-", "<cmd>split<cr>")
map("n", "<LocalLeader>=", "<cmd>vsplit<cr>")

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

map(
  "n",
  "<leader>sr",
  function()
    local word = vim.fn.input("Word: ")
    local replacement = vim.fn.input("Replace with: ")
    vim.api.nvim_command("cfdo %s/" .. word .. "/" .. replacement .. "/g | update | bd")
  end
)
