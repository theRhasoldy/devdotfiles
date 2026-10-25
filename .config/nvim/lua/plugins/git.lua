---@type LazySpec
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Match codediff's hunk navigation (`]g`/`[g`) so the same keys work
      -- in both the buffer and the side-by-side view.
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("]c", function()
          if vim.wo.diff then
            return "]c"
          end
          gs.nav_hunk("next")
          return "<Ignore>"
        end, "Next hunk")
        map("[c", function()
          if vim.wo.diff then
            return "[c"
          end
          gs.nav_hunk("prev")
          return "<Ignore>"
        end, "Prev hunk")
        map("<leader>hp", gs.preview_hunk, "Preview hunk")
        map("<leader>hs", gs.stage_hunk, "Stage hunk")
        map("<leader>hr", gs.reset_hunk, "Reset hunk")
      end,
    },
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      {
        "<leader>gd",
        "<cmd>CodeDiff<cr>",
        desc = "Diff view (working tree)",
      },
      {
        "<leader>gD",
        "<cmd>CodeDiff history %<cr>",
        desc = "File history (current file)",
      },
    },
    opts = {},
  },
}
