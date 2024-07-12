local map = vim.keymap.set

vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= true
  return map(mode, lhs, rhs, opts)
end

return {
  create_autocmd = vim.api.nvim_create_autocmd,
  create_group = vim.api.nvim_create_augroup,
  clear_autocmd = vim.api.nvim_clear_autocmds,
  map = map,
}
