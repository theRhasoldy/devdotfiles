return {
  {

    "saghen/blink.cmp",
    dependencies = {
      {
        "jsongerber/nvim-px-to-rem",
        opts = {
          root_font_size = 16,
          decimal_count = 4,
          show_virtual_text = true,
          add_cmp_source = false,
          filetypes = {
            "css",
            "scss",
            "sass",
            "js",
            "jsx",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "ts",
            "tsx",
            "vue",
            "html",
          },
        },
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-c>"] = {
          function(cmp)
            cmp.show()
          end,
        },
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
          cycle = {
            from_bottom = true,
            from_top = true,
          },
          max_items = 200,
          selection = { preselect = false, auto_insert = false },
        },
        accept = {
          -- Experimental auto-brackets support
          auto_brackets = {
            enabled = true,
            default_brackets = { "(", ")" },
            kind_resolution = {
              enabled = true,
            },
            semantic_token_resolution = {
              enabled = true,
              timeout_ms = 400,
            },
          },
        },
        menu = {
          enabled = true,
          min_width = 20,
          max_height = 15,
          border = "single",
          winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
          scrolloff = 2,
        },
        documentation = {
          treesitter_highlighting = true,
          window = {
            min_width = 20,
            max_width = 60,
            max_height = 30,
            border = "single",
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
          min_width = 20,
          max_width = 100,
          max_height = 10,
          border = "single",
        },
      },
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
      },
      default_format_opts = {
        timeout_ms = 3000,
        lsp_format = "never",
      },
    },
  },
}
