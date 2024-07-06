local path = vim.split(package.path, ";")

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      border = "single",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "lua_ls",
        "bashls",
        "eslint",
        "tsserver",
        "volar",
        "astro",
        "angularls",
        "mdx_analyzer",
        "marksman",
        "html",
        "cssls",
        "tailwindcss",
        "emmet_language_server",
        "yamlls",
        "jsonls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, lsp = pcall(require, "lspconfig")

      if not ok then
        print("error loading lsp config")
        return
      end

      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- builtin vim diagnostics options
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        float = {
          source = "always",
          severity_sort = true,
        },
        virtual_text = {
          spacing = 24,
          source = "always",
          prefix = "󰊠",
          severity_skrt = true,
        },
      })

      -- override mason-lspconfig
      local default_setup = function(server)
        lsp[server].setup({
          capabilities = lsp_capabilities,
        })
      end

      require('mason-lspconfig').setup({
        handlers = {
          -- default setup for all lsp servers
          default_setup,
          -- custom overrides
          lua_ls = function()
            lsp.lua_ls.setup({
              capabilities = lsp_capabilities,
              single_file_support = true,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" },
                  },
                  hint = { enable = true },
                  workspace = {
                    runtime = {
                      version = "luajit",
                      -- Setup your lua path
                      path = path,
                    },
                    library = {
                      -- "~/.local/share/nvim/mason/packages",
                      vim.api.nvim_get_runtime_file("", true),
                    },
                    checkThirdParty = true,
                  },
                  completion = {
                    workspaceWord = true,
                    callSnippet = "Replace",
                  },
                  format = {
                    enable = false,
                  },
                  telemetry = {
                    enable = false,
                  },
                },
              },
            })
          end,
          tsserver = function()
            lsp.tsserver.setup({
              capabilities = lsp_capabilities,
              filetypes = {
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "javascript",
                "javascriptreact",
                "javascript.jsx",
              },
              settings = {
                typescript = {
                  format = { enable = false },
                  inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "literal",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = true,
                  },
                  suggest = {
                    includeCompletionsForModuleExports = true,
                  },
                  referencesCodeLens = { enabled = false },
                  implementationsCodeLens = { enabled = false },
                },
                javascript = {
                  format = { enable = false },
                  inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = true,
                  },
                  suggest = {
                    includeCompletionsForModuleExports = true,
                  },
                  referencesCodeLens = { enabled = false },
                  implementationsCodeLens = { enabled = false },
                },
              },
            })
          end,
        },
      })

      -- global keybinds
      vim.keymap.set('n', "<Leader><Leader>", '<cmd>lua vim.diagnostic.open_float()<cr>')
      vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
      vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

      -- attach these keybinds only if there is an active lsp server
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = {buffer = event.buf}
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end
      })

    end,
  },
}
