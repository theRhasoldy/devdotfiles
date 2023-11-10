return {
  "mfussenegger/nvim-lint",
  -- enabled = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("lint").linters_by_ft = {
      lua = { "stylelint" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      astro = { "eslint_d" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "ModeChanged", "TextChangedI", "TextChanged", "BufEnter", "BufWritePost" }, {
      group = lint_augroup,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
