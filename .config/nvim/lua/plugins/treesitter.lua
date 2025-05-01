local ensure_installed = {
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
  "hyprlang",
  "gitignore",
  "gitcommit",
  "git_rebase",
  "git_config",
}

return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  init = function(plugin)
    require("lazy.core.loader").add_to_rtp(plugin)
    require("nvim-treesitter.query_predicates")
  end,
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
  ---@module "nvim-treesitter.configs"
  ---@type TSConfig
  opts = {
    modules = {},
    ignore_install = {},
    auto_install = true,
    ensure_installed = ensure_installed,
    sync_install = true,
    indent = {
      enable = true,
    },
    highlight = {
      enable = true,
      disable = function(_, buf)
        local max_filesize = 600 * 1024 -- 600 kb
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
          ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
          ["ac"] = "@class.outer",
          ["ic"] = {
            query = "@class.inner",
            desc = "Select inner part of a class region",
          },
          ["as"] = {
            query = "@scope",
            query_group = "locals",
            desc = "Select language scope",
          },
        },
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
        include_surrounding_whitespace = true,
        lookahead = true,
      },
      swap = {
        enable = true,
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = { query = "@class.outer", desc = "Next class start" },
          ["]o"] = "@loop.*",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
        goto_next = {
          ["]c"] = "@conditional.outer",
        },
        goto_previous = {
          ["[c"] = "@conditional.outer",
        },
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
    local ok, treesitter = pcall(require, "nvim-treesitter.configs")

    if not ok then
      print("error loading treesitter")
      return
    end

    treesitter.setup(opts)
  end,
}
