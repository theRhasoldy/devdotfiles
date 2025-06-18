local utils = require("config.utils")

local opt = vim.opt

vim.opt.termguicolors = true

-- files
opt.hidden = true
opt.confirm = true
opt.autoread = true

-- line numbers
opt.rnu = true
opt.nu = true
opt.so = 9999
opt.ss = 20
opt.siso = 9999
opt.sbo = "ver,hor,jump"
opt.sms = true

opt.clipboard = "unnamedplus"

-- statusline
opt.signcolumn = "yes"
opt.laststatus = 3 -- Global Statusline
opt.showmode = false

-- tabs & indents
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.shiftround = true
opt.smartindent = true
opt.autoindent = true

opt.backspace = { "start", "eol", "indent" }

opt.cursorline = true
--- disable blinking
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20"

-- nvim files
opt.swapfile = false
opt.backup = true
opt.backupdir = vim.fn.stdpath("state") .. "/backup"

-- undo
opt.history = 10000
opt.undofile = true
opt.undodir = os.getenv("XDG_CACHE_HOME") .. "/nvim/undo"

-- search
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

opt.wrap = false
opt.equalalways = true

vim.g.markdown_fenced_languages = { "javascript", "typescript", "scss", "css", "html" }
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- add borders to floating windows
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or utils.border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
