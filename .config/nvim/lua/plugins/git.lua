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
    event = "BufReadPre",
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
}
