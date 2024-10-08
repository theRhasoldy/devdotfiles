return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  opts = {
    update_events = { "TextChanged", "TextChangedI" },
  },
  dependencies = {
    "hrsh7th/nvim-cmp",
    {
      "garymjr/nvim-snippets",
      opts = {
        friendly_snippets = true,
      },
      config = function()
        require("luasnip").filetype_extend("javascript", { "javascriptreact" })
        require("luasnip").filetype_extend("javascript", { "html" })
        require("luasnip").filetype_extend("typescript", { "typescriptreact" })
        require("luasnip").filetype_extend("typescript", { "html" })
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
      dependencies = { "rafamadriz/friendly-snippets" },
    },
  },
  keys = {
    {
      "<Tab>",
      function()
        if vim.snippet.active({ direction = 1 }) then
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
          return
        end
        return "<Tab>"
      end,
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<Tab>",
      function()
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      end,
      expr = true,
      silent = true,
      mode = "s",
    },
    {
      "<S-Tab>",
      function()
        if vim.snippet.active({ direction = -1 }) then
          vim.schedule(function()
            vim.snippet.jump(-1)
          end)
          return
        end
        return "<S-Tab>"
      end,
      expr = true,
      silent = true,
      mode = { "i", "s" },
    },
  },
}
