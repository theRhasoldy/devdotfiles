-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Don't animate scrolling while a cmdline is open.
-- With `incsearch`, every typed character jumps the cursor to the next match,
-- and with `scrolloff = 999` every jump scrolls the whole window, so the
-- smooth-scroll animation made searching feel far slower than it is.
local cmdline_scroll = vim.api.nvim_create_augroup("cmdline_scroll", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = cmdline_scroll,
  callback = function()
    vim.b.snacks_scroll = false
  end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = cmdline_scroll,
  callback = function()
    vim.b.snacks_scroll = nil
  end,
})
