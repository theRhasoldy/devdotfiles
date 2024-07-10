local format_autocmd = function(client, bufnr)
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = true })
      end,
    })
  end
end

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
    local actions = none.builtins.code_actions

    none.setup({
      debounce = 150,
      sources = {
        formatting.prettierd.with({ extra_filetypes = { "astro" } }),
        actions.gitsigns,
        diagnostics.selene,
        formatting.stylua,
      },
      on_attach = format_autocmd,
    })
  end,
}
