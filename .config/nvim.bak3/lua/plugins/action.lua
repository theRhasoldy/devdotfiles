return {
  "Chaitanyabsprip/fastaction.nvim",
  event = "LSPAttach",
  ---@type FastActionConfig
  opts = {
    dismiss_keys = { "j", "k", "<C-c>", "<Esc>", "q" },
    keys = "asdfghjkl",
    typescript = {
      { pattern = "fix", key = "f", order = 1 },
      { pattern = "fix all", key = "fa", order = 2 },
      { pattern = "from module", key = "a", order = 3 },
    },
    popup = {
      border = "rounded",
      hide_cursor = true,
      title = "Actions:",
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
