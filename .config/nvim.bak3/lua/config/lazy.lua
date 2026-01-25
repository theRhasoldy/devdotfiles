-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

-- Lazy options
lazy.setup("plugins", {
  defaults = {
    lazy = true,
    -- default `cond` you can use to globally disable a lot of plugins
    cond = nil,
  },
  dev = {
    -- Directory for local plugin projects
    path = "~/Projects/Lua",
  },
  install = {
    colorscheme = { "oxicarbon" },
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrw",
        "netrwSettings",
        "netrwPlugin",
        "netrwFileHandlers",
        "tar",
        "tarPlugin",
        "tohtml",
        "2html_plugin",
        "tutor",
        "tutor_mode_plugin",
        "zip",
        "zipPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "logiPat",
        "rrhelper",
        "rplugin",
      },
    },
  },
  diff = {
    cmd = "diffview.nvim",
  },
  ui = {
    browser = nil,
    border = "single",
    title = "Lazy Config",
    title_pos = "center",
    icons = {
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      source = " ",
      start = "",
      task = "✔ ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
  },
})

-- disable plugins and providers
vim.go.loadplugins = false
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
