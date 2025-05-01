return {
  "Chaitanyabsprip/fastaction.nvim",
  event = "LSPAttach",
  ---@type FastActionConfig
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
      mode = { "n" },
      "ga",
      function()
        require("fastaction").code_action()
      end,
      desc = "Code actions for current file",
    },
    {
      mode = { "v" },
      "ga",
      function()
        require("fastaction").range_code_action()
      end,
      desc = "Code actions for current selection",
    },
  },
}
