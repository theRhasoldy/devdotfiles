local map = vim.keymap.set

-- <CR> opens a line without entering insert mode.
map("n", "<cr>", "o<Esc>")
map("n", "<S-cr>", "O<Esc>")

map("n", "<localleader>-", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<localleader>=", "<cmd>vsplit<cr>", { desc = "Split vertical" })

map("n", "<localleader>h", "<C-W>H", { desc = "Switch to left split" })
map("n", "<localleader>j", "<C-W>J", { desc = "Switch to bottom split" })
map("n", "<localleader>k", "<C-W>K", { desc = "Switch to top split" })
map("n", "<localleader>l", "<C-W>L", { desc = "Switch to right split" })

map("n", "<localleader>H", "<C-W><", { desc = "Resize split left" })
map("n", "<localleader>J", "<C-W>+", { desc = "Resize split down" })
map("n", "<localleader>K", "<C-W>-", { desc = "Resize split up" })
map("n", "<localleader>L", "<C-W>>", { desc = "Resize split right" })

map("n", "n", "nzv", { desc = "Next search result with cursor centered" })
map("n", "N", "Nzv", { desc = "Previous search result with cursor centered" })

map("x", "p", [["_dP]])

map("n", "<leader><leader>", vim.diagnostic.open_float, { desc = "Diagnostic float (current line)" })

-- Mouse wheel scrolls instantly: disable mini.animate's scroll animation while a
-- wheel event is being processed, then restore it.
local wheel_keys = {}
for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>", "<ScrollWheelLeft>", "<ScrollWheelRight>" }) do
  wheel_keys[vim.api.nvim_replace_termcodes(key, true, true, true)] = true
end
vim.on_key(function(key)
  if wheel_keys[key] then
    vim.g.minianimate_disable = true
    vim.defer_fn(function()
      vim.g.minianimate_disable = false
    end, 150)
  end
end)

map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("Autoformat " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "Toggle autoformat" })

---@return string word, string replacement
local function replace_input()
  return vim.fn.input("Word: "), vim.fn.input("Replace with: ")
end

map("n", "<leader>r", function()
  local word, replacement = replace_input()
  vim.cmd("%s/" .. word .. "/" .. replacement)
end, { desc = "Find and replace in current file" })

map("n", "<leader>sr", function()
  local word, replacement = replace_input()
  vim.cmd("cfdo %s/" .. word .. "/" .. replacement .. "/g | update | bd")
end, { desc = "Find and replace for files in quickfix list" })
