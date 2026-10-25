local augroup = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight on yank",
  callback = function()
    vim.hl.hl_op({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position when reopening a file",
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  desc = "Keep splits equal on resize",
  command = "tabdo wincmd =",
})
