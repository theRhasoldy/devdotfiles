return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = true,
      float = {
        source = "if_many",
        border = "rounded",
      },
      virtual_text = {
        spacing = 10,
        source = "if_many",
        prefix = "󰊠",
        hl_mode = "combine",
      },
      severity_sort = true,
    },
    inlay_hints = { enabled = false },
    servers = {
      ["*"] = {
        on_attach = function(_, bufnr)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "<leader><leader>", vim.diagnostic.open_float, "Floating Diagnostics")
          map("n", "gs", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
        end,
        handlers = {
          ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
          ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = "rounded" }),
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            completion = { callSnippet = "Replace" },
          },
        },
      },
      tailwindcss = {
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              },
            },
          },
        },
      },
      emmet_language_server = {},
      astro = {},
      mdx_analyzer = {},
      marksman = {},
      html = {},
      cssls = {
        settings = {
          css = { lint = { unknownAtRules = "ignore" } },
          scss = { lint = { unknownAtRules = "ignore" } },
        },
      },
      yamlls = {},
      jsonls = {},
    },
    eslint = function()
      if not auto_format then
        return
      end

      local formatter = LazyVim.lsp.formatter({
        name = "eslint: lsp",
        primary = false,
        priority = 200,
        filter = "eslint",
      })

      -- register the formatter with LazyVim
      LazyVim.format.register(formatter)
    end,
  },
}
