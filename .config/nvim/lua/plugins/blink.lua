local symbols = require("config.utils").symbols

return {
  "saghen/blink.cmp",
  version = "v0.*",
  event = { "LSPAttach", "BufReadPost", "BufNewFile" },
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
    completion = {
      list = {
        -- Maximum number of items to display
        max_items = 200,
        -- Controls if completion items will be selected automatically,
        -- and whether selection automatically inserts
        selection = "manual",
      },
      accept = {
        -- Experimental auto-brackets support
        auto_brackets = {
          enabled = true,
          default_brackets = { "(", ")" },
          kind_resolution = {
            enabled = true,
            blocked_filetypes = { "typescriptreact", "javascriptreact", "vue" },
          },
          semantic_token_resolution = {
            enabled = true,
            blocked_filetypes = {},
            timeout_ms = 400,
          },
        },
      },
      menu = {
        enabled = true,
        min_width = 20,
        max_height = 15,
        border = "rounded",
        winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
        scrolloff = 2,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        treesitter_highlighting = true,
        window = {
          min_width = 20,
          max_width = 60,
          max_height = 30,
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
          scrollbar = true,
        },
      },
    },
    -- Experimental signature help support
    signature = {
      enabled = true,
      window = {
        min_width = 1,
        max_width = 100,
        max_height = 10,
        border = "rounded",
      },
    },
    sources = {
      completion = {
        enabled_providers = function()
          local node = vim.treesitter.get_node()
          if
            node and vim.tbl_contains({ "comment", "line_comment", "block_comment" })
          then
            return { "buffer" }
          else
            return { "lsp", "path", "snippets", "buffer" }
          end
        end,
      },
    },
    appearance = {
      kind_icons = symbols,
    },
  },
}
