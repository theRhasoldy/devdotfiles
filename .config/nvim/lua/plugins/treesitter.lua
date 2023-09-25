return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-context",
        name = "treesitter-context",
        opts = { separator = "" },
        keys = {
          {
            "gtc",
            function()
              require("treesitter-context").go_to_context()
            end,
            desc = "Go to context",
          },
        },
      },
      {
        "windwp/nvim-autopairs",
        opts = {
          enable_check_bracket_line = true,
          check_ts = true,
          ts_config = {
            javascript = { "template_string" },
          },
        },
      },
      {
        "windwp/nvim-ts-autotag",
      },
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      {},
    },
    opts = {
      ensure_installed = {
        "lua",
        "bash",
        "html",
        "css",
        "scss",
        "astro",
        "javascript",
        "typescript",
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
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
      highlight = {
        custom_captures = {},
        disable = {},
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        disable = {},
        enable = true,
      },
      indent = {
        disable = {},
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
            ["ac"] = "@class.outer",
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = true,
        },
      },
      matchup = { enable = true },
      autotag = { enable = true },
      pairs = { enable = true },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    init = function()
      vim.o.matchpairs = "(:),{:},[:],<:>"
    end,
    config = function()
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
    end,
  },
}
