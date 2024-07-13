local utils = require("config.utils")
local path = vim.split(package.path, ";")

local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }

-- global keybinds
local get_keybinds_on_lsp = function()
  local ok, telescope = pcall(require, "telescope.builtin")

  if not ok then
    print("error loading telescope")
    return
  end

  utils.map("n", "<Leader><Leader>", "<cmd>lua vim.diagnostic.open_float()<cr>")

  utils.map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
  utils.map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

  -- attach these keybinds only if there is an active lsp server
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
      local telescope_opts = { reuse_win = true }

      utils.map(
        "n",
        "K",
        "<cmd>lua vim.lsp.buf.hover()<cr>",
        { buffer = event.buf, desc = "Hover doc" }
      )
      utils.map(
        "n",
        "gs",
        "<cmd>lua vim.lsp.buf.signature_help()<cr>",
        { buffer = event.buf, desc = "Signature help" }
      )

      -- go to (with telescope)
      utils.map("n", "gd", function()
        telescope.lsp_definitions(telescope_opts)
      end, { buffer = event.buf, desc = "Go to definition" })

      utils.map(
        "n",
        "gD",
        "<cmd>lua vim.lsp.buf.declaration()<cr>",
        { buffer = event.buf, desc = "Go to declaration" }
      )

      utils.map("n", "gi", function()
        telescope.lsp_implementations(telescope_opts)
      end, { buffer = event.buf, desc = "Go to implementation" })
      utils.map("n", "gt", function()
        telescope.lsp_type_definitions(telescope_opts)
      end, { buffer = event.buf, desc = "Go to type definition" })
      utils.map("n", "gr", function()
        telescope.lsp_references(telescope_opts)
      end, { buffer = event.buf, desc = "Go to references" })

      -- code actions and modif
      -- utils.map('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<cr>', opts) // handled by inc-rename.nvim

      -- format buffer
      utils.map(
        { "n", "x" },
        "==",
        "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
        { buffer = event.buf, desc = "Format buffer" }
      )

      -- utils.map(
      --   "n",
      --   "ga",
      --   "<cmd>lua vim.lsp.buf.code_action()<cr>",
      --   { buffer = event.buf, desc = "Code action" }
      -- ) -- handled by fastaction.nvim
    end,
  })
end

-- display virtual text in normal only
local hide_virtual_in_insert = function()
  utils.create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
      vim.diagnostic.config({
        virtual_text = false,
      })
    end,
  })
  utils.create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
      vim.diagnostic.config({
        virtual_text = true,
      })
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
      local ok_mason, mason = pcall(require, "mason-lspconfig")

      if not ok_lsp or not ok_mason then
        print("error loading lsp config")
        return
      end

      local cmp_capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

      local lsp_defaults =
        vim.tbl_deep_extend("force", lsp_capabilities, cmp_capabilities)

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
          severity_sort = true,
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
          capabilities = lsp_defaults,
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
      hide_virtual_in_insert()
    end,
  },
}
