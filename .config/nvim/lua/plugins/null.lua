return {
  "nvimtools/none-ls.nvim", -- configure formatters & linters
  -- enabled = false,
  event = "BufReadPre",
  config = function()
    local null = require("null-ls")

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    local formatting = null.builtins.formatting
    local diagnostics = null.builtins.diagnostics
    local completions = null.builtins.completion
    local actions = null.builtins.code_actions

    null.setup({
      debounce = 150,
      sources = {
        completions.luasnip.with({ filetypes = { "astro", "typescript", "javascript", "typescriptreact", "javascriptreact" } }),
        actions.gitsigns,
        diagnostics.selene,
        formatting.prettierd.with({ extra_filetypes = { "astro" } }),
        formatting.stylua,
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end,
    })
  end,
}
