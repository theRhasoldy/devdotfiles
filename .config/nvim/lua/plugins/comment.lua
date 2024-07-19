return {
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "VeryLazy",
  },
}
