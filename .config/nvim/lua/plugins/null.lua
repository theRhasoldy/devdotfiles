return {
  "jose-elias-alvarez/null-ls.nvim",
  enabled = false,
  event = "BufReadPre",
  config = function()
    local null = require("null-ls")

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    local formatting = null.builtins.formatting
    local diagnostics = null.builtins.diagnostics

    null.setup({
      debounce = 150,
      sources = {
        -- null.builtins.code_actions.gitsigns,
        formatting.prettierd.with({ extra_filetypes = { "astro" } }),
        formatting.fixjson,
        formatting.stylua,
        diagnostics.luacheck,
        diagnostics.eslint_d.with({
          diagnostics_format = "[eslint] #{m}\n(#{c})",
          extra_filetypes = { "astro" },
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc.cjs" or ".eslintrc" })
          end,
        }),
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
