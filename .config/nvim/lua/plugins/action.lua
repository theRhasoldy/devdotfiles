return {
  "Chaitanyabsprip/fastaction.nvim",
  event = "LSPAttach",
  opts = {
    dismiss_keys = { "j", "k", "<C-c>", "<Esc>", "q" },
    keys = "qwertyuiopasdfghlzxcvbnm",
    popup = {
      border = "rounded",
      hide_cursor = true,
      title = "Code Actions:",
    },
  },
  keys = {
    {
      "ga",
      function()
        require("fastaction").code_action()
      end,
      desc = "Search files",
    },
  },
}
