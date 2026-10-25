---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        -- Global (not LspAttach): formatting must work in buffers no server
        -- attached to, e.g. json or markdown files.
        "<leader>cf",
        function()
          require("conform").format({ async = false, lsp_format = "never" })
        end,
        desc = "Format buffer",
      },
    },
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        astro = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        fish = { "fish_indent" },
      },
      format_on_save = function()
        if not vim.g.autoformat then
          return nil
        end
        return { timeout_ms = 500, lsp_format = "never" }
      end,
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    ---@type LintConfig
    opts = {
      linters_by_ft = {
        lua = { "selene" },
        markdown = { "markdownlint-cli2" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("lint_on_event", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
