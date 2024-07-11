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
          winbar_info = true,
          disable_diagnostics = false,
        },
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          disable_diagnostics = false,
          layout = "diff4_mixed",
          winbar_info = false,
        },
        file_history = {
          -- Config for changed files in file history views.
          disable_diagnostics = false,
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },
      file_panel = {
        listing_style = "list",
      },
    },
    keys = {
      {
        "<leader>gd",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
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
