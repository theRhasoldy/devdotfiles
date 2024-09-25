return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "onsails/lspkind-nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
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
      performance = {
        debounce = 150,
        throttle = 100,
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
      confirmation = {
        get_commit_characters = function()
          return {}
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-c>"] = cmp.mapping({
          i = cmp.mapping.complete(),
          c = function()
            if cmp.visible() then
              if not cmp.confirm({ select = true }) then
                return
              end
            else
              cmp.complete()
            end
          end,
        }),
        ["<C-n>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<C-p>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<C-u>"] = cmp.mapping.scroll_docs(4),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        -- ["<Esc>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({
          select = true,
          behavior = cmp.ConfirmBehavior.Replace,
        }),
        ["<Tab>"] = nil,
        ["<S-Tab>"] = nil,
      }),
    })

    cmp.setup.filetype("lua", {
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 5 },
        { name = "luasnip", keyword_length = 2, max_item_count = 10, group_index = 3 },
        { name = "path" },
        { name = "buffer", keyword_length = 5, max_item_count = 10 },
      }),
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "nvim_lsp_document_symbol" },
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
