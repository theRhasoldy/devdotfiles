local utils = require("config.utils")

local augroup = utils.create_group("LspFormatting", {})

local format_autocmd = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    utils.clear_autocmd({ group = augroup, buffer = bufnr })
    utils.create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

return {
  "nvimtools/none-ls.nvim",
  event = "LSPAttach",
  config = function()
    local ok, none = pcall(require, "null-ls")

    if not ok then
      print("error loading none-ls")
      return
    end

    local formatting = none.builtins.formatting
    local diagnostics = none.builtins.diagnostics

    none.setup({
      debounce = 150,
      sources = {
        formatting.prettierd.with({ extra_filetypes = { "astro" } }),
        diagnostics.selene,
        formatting.stylua,
      },
      on_attach = format_autocmd,
    })
  end,
}
