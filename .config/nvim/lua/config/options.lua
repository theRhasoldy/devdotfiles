-- Global LazyVim Flags (Set these first)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g.autoformat = true
-- TypeScript LSP: vtsls by default (uses the project's own TS version).
-- lua/plugins/lsp.lua additionally enables the native TS 7 `tsc` server for
-- projects whose tsconfig is TS 7 ready (no `baseUrl`), or that contain a `.tsgo` file.
vim.g.lazyvim_ts_lsp = "vtsls"

-- formatting is done by conform (prettierd), not the eslint LSP
vim.g.lazyvim_eslint_auto_format = false
vim.g.snacks_animate = true

-- Standard Neovim Options
local opt = vim.opt

opt.title = true
opt.titlestring = "%{expand('%:p:h:t')}/%t"

opt.relativenumber = true
opt.scrolloff = 999 -- Keeps cursor centered

-- LazyVim's statuscolumn is `%!v:lua.LazyVim.statuscolumn()` (snacks.statuscolumn):
-- a Lua call per visible line on *every* redraw. Its cache key includes the
-- relative line number, so with relativenumber on it misses for every line on
-- every scroll. This native expression draws the same thing (signs + relative
-- numbers, absolute on the cursor line) from C with no Lua call per line:
opt.statuscolumn = [[%s%{v:relnum == 0 ? v:lnum : v:relnum} ]]
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20"
opt.hlsearch = false
opt.winborder = "single"

-- Your preferred file handling
opt.swapfile = false
opt.undofile = true
opt.backup = false

-- Keep LazyVim's default indenting (2 spaces)
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

-- Ensure True Color support
opt.termguicolors = true
