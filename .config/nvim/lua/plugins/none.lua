local utils = require("config.utils")

local augroup = utils.create_group("LspFormatting", {})

return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local ok, none = pcall(require, "null-ls")

    if not ok then
      print("error loading none-ls")
      return
    end

    local formatting = none.builtins.formatting
    local diagnostics = none.builtins.diagnostics

    vim.cmd([[cabbrev wq execute "lua vim.lsp.buf.format()" <bar> wq]])

    none.setup({
      debounce = 150,
      sources = {
        formatting.prettierd,
        diagnostics.selene,
        formatting.stylua,
      },
      on_attach = function(_, bufnr)
        utils.clear_autocmd({ group = augroup, buffer = bufnr })
        utils.create_autocmd("BufWritePost", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              async = true,
            })
          end,
        })
      end,
    })
  end,
}
