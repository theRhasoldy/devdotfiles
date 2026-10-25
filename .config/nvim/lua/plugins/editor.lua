---@type LazySpec
return {
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    ---@type MiniAiConfig
    opts = {
      -- JSX/TSX nesting is deep; the default 50 lines misses the enclosing
      -- element in any real component.
      n_lines = 500,
    },
  },
  {
    "nvim-mini/mini.comment",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.move",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    ---@type MiniSurroundConfig
    opts = {
      -- `gs` prefix instead of the `sa`/`sd`/`sr`/`sf` defaults: every `s*`
      -- mapping would otherwise hold back plain `s` (substitute) for
      -- `timeoutlen`, which reads as a dead key.
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
      },
    },
  },
  {
    "nvim-mini/mini.splitjoin",
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    ---@type AutotagConfig
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
  {
    "nvim-mini/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Delete buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete buffer (force)",
      },
    },
    opts = {},
  },
}
