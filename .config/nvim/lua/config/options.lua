local opt = vim.opt

vim.opt.termguicolors = true

-- files
opt.hidden = true
opt.confirm = true
opt.autoread = true

-- line numbers
opt.rnu = true
opt.nu = true

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
