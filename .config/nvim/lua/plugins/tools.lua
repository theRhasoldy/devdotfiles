return {
  {
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    opts = {
      ignoreSpecialBuftypes = false,
      notificationOnAutoClose = true,
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      key_labels = {
        ["<space>"] = "spc",
        ["<CR>"] = "ret",
        ["<tab>"] = "tab",
      },
      window = {
        border = "single", -- none, single, double, shadow
        winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          -- Available layouts:
          --  'diff1_plain'
          --    |'diff2_horizontal'
          --    |'diff2_vertical'
          --    |'diff3_horizontal'
          --    |'diff3_vertical'
          --    |'diff3_mixed'
          --    |'diff4_mixed'
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          layout = "diff4_mixed",
          disable_diagnostics = false,
          winbar_info = true,
        },
        file_history = {
          -- Config for changed files in file history views.
          layout = "diff2_horizontal",
          winbar_info = true,
        },
      },
    },
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<CR>",
        desc = "Open diff view window",
      },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 48
    end,
    keys = {
      {
        "<leader>u",
        "<cmd>UndotreeToggle<CR>",
        desc = "Toggle undo tree",
      },
    },
  },
}
