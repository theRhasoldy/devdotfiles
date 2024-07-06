return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    {
      "L3MON4D3/LuaSnip",
      opts = {
        keep_roots = true,
        update_events = { "TextChanged", "TextChangedI" },
      },
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip").filetype_extend("js" or "jsx", { "javascript" })
          require("luasnip").filetype_extend("ts" or "tsx", { "typescript" })
          require("luasnip").filetype_extend("astro", { "typescript", "javascript" })
          require("luasnip").filetype_extend("lua", { "lua" })
        end,
      },
      keys = {
        {
          "<Tab>",
          mode = { "i", "s" },
          function()
            if require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            else
              return "<Tab>"
            end
          end,
          expr = true,
          silent = true,
        },
        {
          "<s-Tab>",
          mode = { "i", "s" },
          function()
            if require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            end
          end,
          expr = true,
          silent = true,
        },
      },
    },
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      view = {
        docs = {
          auto_open = true,
        },
      },
      window = {
        documentation = cmp.config.window.bordered({
          winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
        }),
        completion = cmp.config.window.bordered({
          winhighlight = "Normal:Normal,CursorLine:PmenuSel,Search:None",
        }),
      },
      formatting = {
        format = require("lspkind").cmp_format({
          mode = "symbol",
          menu = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
            latex_symbols = "[Latex]",
          },
        }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 5 },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer", keyword_length = 3, max_item_count = 10, group_index = 3 },
      }),
      mapping = {
        ["<C-J>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-K>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-u>"] = cmp.mapping.scroll_docs(4),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-c>"] = cmp.mapping({
          i = cmp.mapping.complete(),
          c = function(
            _ --[[fallback]]
            )
            if cmp.visible() then
              if not cmp.confirm({ select = true }) then
                return
              end
            else
              cmp.complete()
            end
          end,
        }),
        -- ["<Esc>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = nil,
        ["<S-Tab>"] = nil,
        ["<C-n>"] = nil,
        ["<C-p>"] = nil,
      },
    })

    cmp.setup.filetype("lua", {
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 5 },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer", keyword_length = 5, max_item_count = 10 },
      }),
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
      },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" },
      }),
    })
  end,
}
