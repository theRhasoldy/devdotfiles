return {
  {
    "numToStr/Comment.nvim",
    config = function()
      local ok, comment_string =
        pcall(require, "ts_context_commentstring.integrations.comment_nvim")

      if not ok then
        print("error loading comment_string")
        return
      end

      require("Comment").setup({
        -- Use treesitter-commentstring to detect comments in jsx, astro... etc
        pre_hook = comment_string.create_pre_hook(),
      })
    end,
    keys = {
      { "gc", mode = { "v" }, desc = "Comment toggle for selection" },
      { "gb", mode = { "v" }, desc = "Block comment toggle for selection" },
      { "gcc", mode = { "n" }, desc = "Line comment toggle" },
      { "gbc", mode = { "n" }, desc = "Block comment toggle" },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "LSPAttach",
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      highlight = {
        before = "", -- "fg" or "bg" or empty
        keyword = "wide_fg", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = "", -- "fg" or "bg" or empty
      },
    },
    keys = {
      {
        "<leader>ft",
        "<cmd>TodoTelescope<cr>",
        desc = "Toggle todo comments",
      },
    },
  },
}
