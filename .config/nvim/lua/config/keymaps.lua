local utils = require("config.utils")
local map = utils.map

-- make all keymaps silent by default
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- reload config
map("n", "<leader>R", "<cmd>source<CR>", { desc = "Reload config" })

-- add new line
map("n", "<cr>", "o<Esc>")
map("n", "<S-cr>", "O<Esc>")

-- splits
map("n", "<LocalLeader>-", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<LocalLeader>=", "<cmd>vsplit<cr>", { desc = "Split vertical" })

-- switch splits
map("n", "<LocalLeader>h", "<C-W>H", { desc = "Switch to left split" })
map("n", "<LocalLeader>j", "<C-W>J", { desc = "Switch to bottom split" })
map("n", "<LocalLeader>k", "<C-W>K", { desc = "Switch to top split" })
map("n", "<LocalLeader>l", "<C-W>L", { desc = "Switch to right split" })

-- resize splits
map("n", "<LocalLeader>H", "<C-W><", { desc = "Resize split left" })
map("n", "<LocalLeader>J", "<C-W>+", { desc = "Resize split down" })
map("n", "<LocalLeader>K", "<C-W>-", { desc = "Resize split up" })
map("n", "<LocalLeader>L", "<C-W>>", { desc = "Resize split right" })

-- yanking
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- search and replace
map(
  "n",
  "<leader>sr",
  -- multiple files using quickfix list
  function()
    local word = vim.fn.input("Word: ")
    local replacement = vim.fn.input("Replace with: ")
    vim.api.nvim_command("cfdo %s/" .. word .. "/" .. replacement .. "/g | update | bd")
  end,
  { desc = "Find and replace for files in quicklist" }
)

-- find and replace
map(
  "n",
  "<leader>r",
  -- multiple files using quickfix list
  function()
    local word = vim.fn.input("Word: ")
    local replacement = vim.fn.input("Replace with: ")
    vim.api.nvim_command("%s/" .. word .. "/" .. replacement)
  end,
  { desc = "Find and replace in current file" }
)
