local symbols = require("config.utils").symbols

return {
  "saghen/blink.cmp",
  version = "v0.*",
  event = "InsertEnter",
  dependencies = "rafamadriz/friendly-snippets",
  opts = {
    keymap = {
      ["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
    accept = {
      auto_brackets = {
        enabled = true,
        default_brackets = { "(", ")" },
      },
    },
    trigger = {
      signature_help = {
        enabled = true,
      },
    },
    sources = {
      completion = {
        enabled_providers = { "lsp", "path", "snippets", "buffer" },
      },
    },
    windows = {
      autocomplete = {
        min_width = 30,
        max_height = 15,
        border = "rounded",
        auto_show = true,
        selection = "manual",
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
      documentation = {
        min_width = 10,
        max_width = 60,
        max_height = 30,
        border = "rounded",
        winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
        auto_show = true,
      },
      signature_help = {
        min_width = 1,
        max_width = 100,
        max_height = 10,
        border = "rounded",
        winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
      },
    },
    -- don't show completions or signature help for these filetypes. Keymaps are also disabled.
    blocked_filetypes = {},
    kind_icons = symbols,
  },
}
