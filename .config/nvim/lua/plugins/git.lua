local signs = {
  add = "│",
  change = "│",
  delete = "_",
  topdelete = " ̅",
  changedelete = "~",
}

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufRead", "BufNewFile" },
    opts = {
      signs = {
        add = { text = signs.add },
        change = { text = signs.change },
        delete = { text = signs.delete },
        topdelete = { text = signs.topdelete },
        changedelete = {
          text = signs.changedelete,
        },
      },
      signcolumn = true,
      numhl = false,
      current_line_blame_opts = {
        delay = 100,
      },
      worktrees = {
        gitdir = { "~/.config/dotfiles.git", "~/.config/devdotfiles.git" },
      },
    },
    keys = {
      {
        "<Leader>bb",
        "<cmd>Gitsigns toggle_current_line_blame<CR>",
        desc = "Toggle line blame",
      },
    },
  },
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    opts = {
      symbols = {
        merge_commit = "M",
        commit = "*",
      },
      format = {
        timestamp = "%H:%M:%S %d-%m-%Y",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
    },
    init = function()
      vim.keymap.set("n", "<leader>gl", function()
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
      end, { desc = "new git graph" })
    end,
  },
}
