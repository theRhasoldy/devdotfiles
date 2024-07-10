local create_autocmd = vim.api.nvim_create_autocmd
local create_group = vim.api.nvim_create_augroup

-- Format Options
local FormatOptions = create_group("FormatOptions", { clear = true })
create_autocmd("BufEnter", {
  group = FormatOptions,
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})
