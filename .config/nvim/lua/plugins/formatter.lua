return {
  "stevearc/conform.nvim",
  -- enabled = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        json = { "fixjson" },
      },
      format_on_save = {
        timeout_ms = 2000,
        async = false,
        lsp_fallback = true,
      },
      format_after_save = {
        lsp_fallback = true,
      },
      log_level = vim.log.levels.WARN,
      notify_on_error = true,
    })
  end,
}
