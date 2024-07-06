return {
  "nvim-treesitter/nvim-treesitter",
  event = { "VeryLazy" },
  build = ":TSUpdate",
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  -- additional modules
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    {
      "nvim-treesitter/nvim-treesitter-context",
      opts = {
        separator = "",
        max_lines = 4,
      },
    },
  },
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "bash",
      "html",
      "css",
      "scss",
      "astro",
      "javascript",
      "typescript",
      "angular",
      "tsx",
      "json",
      "yaml",
      "rasi",
      "markdown",
      "markdown_inline",
      "vimdoc",
      "diff",
      "gitignore",
      "gitcommit",
      "git_rebase",
      "git_config",
    },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = true,

    -- config for default modules
    indent = {
      enable = true,
    },
    highlight = {
      enable = true,
      -- disable for large files
      disable = function(_, buf)
        local max_filesize = 600 * 1024 -- 600 kb
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    -- config for additional modules
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
      },
      swap = {
        enable = true,
      },
      move = {
        enable = true,
      },
      lsp_interop = {
        enable = true,
      },
    },
    matchup = {
      enabled = true,
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
