return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = {
          text = "/",
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
