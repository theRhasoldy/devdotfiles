local utils = require("config.utils")

local augroup = utils.create_group("LspFormatting", {})

return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  enabled = false,
  config = function()
    local ok, none = pcall(require, "null-ls")

    if not ok then
      print("error loading none-ls")
      return
    end

    local formatting = none.builtins.formatting
    local diagnostics = none.builtins.diagnostics

    -- vim.cmd([[cabbrev wq execute "lua vim.lsp.buf.format()" <bar> wq]])

    none.setup({
      debounce = 150,
      sources = {
        formatting.prettierd,
        -- formatting.sql_formatter.with({ command = { "sleek" } }),
        diagnostics.selene,
        formatting.stylua,
        formatting.sql_formatter,
      },
      on_attach = function(_, bufnr)
        utils.clear_autocmd({ group = augroup, buffer = bufnr })
        utils.create_autocmd("BufWrite", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              async = false,
            })
          end,
        })
      end,
    })
  end,
}
