return {
  {
    "chrisgrieser/nvim-early-retirement",
    event = "VeryLazy",
    opts = {
      ignoreSpecialBuftypes = false,
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
        ["<space>"] = "<space>",
        ["<CR>"] = "<cr",
        ["<tab>"] = "<tab>",
      },
      window = {
        border = "single",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          layout = "diff4_mixed",
          disable_diagnostics = false,
          winbar_info = false,
        },
        file_history = {
          -- Config for changed files in file history views.
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },
    },
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<CR>",
        desc = "Open diff view window",
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory<CR>",
        desc = "Open file history view window",
      },
    },
  },
}
