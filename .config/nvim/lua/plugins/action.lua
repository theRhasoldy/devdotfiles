return {
  "luckasRanarison/clear-action.nvim",
  event = "LSPAttach",
  opts = {
    popup = {
      enable = true,
      border = "rounded",
      hide_cursor = true,
      highlights = {
        header = "Function",
        label = "Statement",
        title = "Normal",
      },
    },
    signs = {
      highlights = {
        quickfix = "Statement",
        refactor = "Delimiter",
        source = "Function",
        combined = "Type",
        label = "Comment",
      },
      icons = {
        quickfix = "󰖷",
        refactor = "󱐋",
        source = "",
        combined = "󰌵", -- used when combine is set to true or as a fallback when there is no action kind
      },
    },
    mappings = {
      code_action = { key = "ga", mode = { "n" }, options = { desc = "Code Action" } },
    },
  },
}
