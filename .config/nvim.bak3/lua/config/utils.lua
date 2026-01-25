local map = vim.keymap.set

vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= true
  return map(mode, lhs, rhs, opts)
end

local symbols = {
  Text = "󰚞",
  Method = "󰆩",
  Function = "󰊕",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "󱉸",
  Value = "󱢏",
  Enum = "",
  Keyword = "",
  Snippet = "󰆐",
  Color = "󰌁",
  File = "󰈔",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "󱌣",
  TypeParameter = "󰉺",
}

local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}

local signs = {
  ERROR = " ",
  WARN = " ",
  HINT = "󰌵 ",
  INFO = " "
}

return {
  sympols = symbols,
  border = border,
  signs = signs,
  create_autocmd = vim.api.nvim_create_autocmd,
  create_group = vim.api.nvim_create_augroup,
  clear_autocmd = vim.api.nvim_clear_autocmds,
  map = map,
}
