-- Global LazyVim Flags (Set these first)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.g.autoformat = true
vim.g.snacks_animate = true

-- Standard Neovim Options
local opt = vim.opt

-- Your preferred visual tweaks
opt.relativenumber = true
opt.scrolloff = 999 -- Keeps cursor centered
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20"
opt.hlsearch = false
opt.winborder = "single"
opt.autochdir = true

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
