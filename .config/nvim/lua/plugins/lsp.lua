local path = vim.split(package.path, ";")

local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }

-- global keybinds
local get_keybinds_on_lsp = function()
  local ok, telescope = pcall(require, "telescope.builtin")

  if not ok then
    print("error loading telescope")
    return
  end

  vim.keymap.set("n", "<Leader><Leader>", "<cmd>lua vim.diagnostic.open_float()<cr>")

  vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
  vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

  -- attach these keybinds only if there is an active lsp server
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
      local opts = { buffer = event.buf, noremap = true }
      local telescope_opts = { reuse_win = true }

      vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
      vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)

      -- go to (with telescope)
      vim.keymap.set("n", "gd", function()
        telescope.lsp_definitions(telescope_opts)
      end, opts)

      vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)

      vim.keymap.set("n", "gi", function()
        telescope.lsp_implementations(telescope_opts)
      end, opts)
      vim.keymap.set("n", "gt", function()
        telescope.lsp_type_definitions(telescope_opts)
      end, opts)
      vim.keymap.set("n", "gr", function()
        telescope.lsp_references(telescope_opts)
      end, opts)

      -- code actions and modif
      -- vim.keymap.set('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<cr>', opts) // handled by inc-rename.nvim

      -- format buffer
      vim.keymap.set(
        { "n", "x" },
        "==",
        "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
        opts
      )

      vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
    end,
  })
end

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
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        -- lsps
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
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local ok_lsp, lsp = pcall(require, "lspconfig")
      local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local ok_mason, mason = pcall(require, "mason-lspconfig")

      if not ok_lsp or not ok_cmp_nvim_lsp or not ok_mason then
        print("error loading lsp config")
        return
      end

      local lsp_capabilities = cmp_nvim_lsp.default_capabilities()

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

      -- Set Custom Icons
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
      end

      -- override mason-lspconfig
      local default_setup = function(server)
        lsp[server].setup({
          capabilities = lsp_capabilities,
        })
      end

      mason.setup({
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

      get_keybinds_on_lsp()
    end,
  },
}
