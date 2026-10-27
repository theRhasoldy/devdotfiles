local g = vim.g
local opt = vim.opt
local constants = require("config.constants")

-- Make ripgrep honour the repo's exclude list (node_modules, build outputs, ...)
vim.env.RIPGREP_CONFIG_PATH = vim.fn.stdpath("config") .. "/ripgreprc"

g.mapleader = " "
g.maplocalleader = ","

g.autoformat = true

opt.title = true
opt.titlestring = "%{expand('%:p:h:t')}/%t"

opt.number = true
opt.relativenumber = true
opt.scrolloff = 999 -- Keeps cursor centered

opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20"
opt.hlsearch = false
opt.winborder = constants.border
opt.signcolumn = "yes"

opt.swapfile = false
opt.undofile = true
opt.confirm = true

opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.undolevels = 10000

opt.splitright = true
opt.splitbelow = true
opt.mouse = "a"
opt.updatetime = 200
opt.laststatus = 3
opt.termguicolors = true
opt.clipboard:append("unnamedplus")
opt.isfname:append("@-@")

-- The statusline shows the mode; keep the mode text out of the message line.
opt.showmode = false

-- Markdown carries its markup in the text (fences, `**`, link brackets, quote
-- bars). 2 hides those blocks outright; `nc` keeps the compact view on the
-- cursor line, so raw syntax only comes back while inserting.
opt.conceallevel = 2
opt.concealcursor = "nc"

-- Glyphs live in config/constants.lua, already keyed by severity.
local severity_sign = vim.tbl_map(function(entry)
  return entry.glyph
end, constants.diagnostics)

vim.diagnostic.config({
  signs = { text = severity_sign },
  virtual_text = {
    current_line = true,
    spacing = 4,
    prefix = function(diagnostic)
      return severity_sign[diagnostic.severity] or ""
    end,
  },
  severity_sort = true,
  update_in_insert = false,
  float = { border = constants.border, source = true },
})
