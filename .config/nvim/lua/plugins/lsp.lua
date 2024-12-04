local utils = require("config.utils")
local path = vim.split(package.path, ";")

-- global keybinds
local get_keybinds_on_lsp = function()
  local ok, telescope = pcall(require, "telescope.builtin")

  if not ok then
    print("error loading telescope")
    return
  end

  local cinnamon_ok, cinnamon = pcall(require, "cinnamon")

  if not cinnamon_ok then
    print("error loading cinnamon")
    return
  end

  utils.map("n", "<Leader><Leader>", function()
    vim.diagnostic.open_float()
  end)

  utils.map("n", "[d", function()
    cinnamon.scroll(vim.diagnostic.goto_prev)
  end)
  utils.map("n", "]d", function()
    cinnamon.scroll(vim.diagnostic.goto_next)
  end)

  -- attach these keybinds only if there is an active lsp server
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
      local telescope_opts = { reuse_win = true }

      utils.map("n", "K", function()
        vim.lsp.buf.hover()
      end, { desc = "Hover doc" })
      utils.map("n", "gs", function()
        vim.lsp.buf.signature_help()
      end, { desc = "Signature help" })

      -- go to (with telescope)
      utils.map("n", "gd", function()
        telescope.lsp_definitions(telescope_opts)
      end, { desc = "Go to definition" })

      utils.map("n", "gD", function()
        vim.lsp.buf.declaration()
      end, { desc = "Go to declaration" })

      utils.map("n", "gi", function()
        telescope.lsp_implementations(telescope_opts)
      end, { desc = "Go to implementation" })
      utils.map("n", "gt", function()
        telescope.lsp_type_definitions(telescope_opts)
      end, { desc = "Go to type definition" })
      utils.map("n", "gr", function()
        telescope.lsp_references(telescope_opts)
      end, { desc = "Go to references" })

      -- code actions and modif
      -- utils.map('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<cr>', opts) // handled by inc-rename.nvim

      -- format buffer
      utils.map({ "n", "x" }, "==", function()
        vim.lsp.buf.format({ async = true })
      end, { buffer = event.buf, desc = "Format buffer" })

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
    cmd = "Mason",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufRead",
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        init = function()
          local ok, wf = pcall(require, "vim.lsp._watchfiles")
          if ok then
            wf._watchfunc = function()
              return function() end
            end
          end
        end,
        opts = {
          ensure_installed = {
            -- lsps
            "lua_ls",
            "bashls",
            "ts_ls",
            "eslint",
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
    },
    config = function()
      local ok_lsp, lsp = pcall(require, "lspconfig")
      local ok_mason, mason = pcall(require, "mason-lspconfig")

      if not ok_lsp or not ok_mason then
        print("error loading lsp config")
        return
      end

      local cmp_capabilities = nil
      if pcall(require, "blink.cmp") then
        cmp_capabilities = require("blink.cmp").get_lsp_capabilities()
      end

      local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

      local capabilities =
        vim.tbl_deep_extend("force", lsp_capabilities, cmp_capabilities)

      local default_setup = function(server)
        lsp[server].setup({
          capabilities = capabilities,
        })
      end

      mason.setup({
        handlers = {
          -- default setup for all lsp servers
          default_setup,
          -- custom overrides
          lua_ls = function()
            lsp.lua_ls.setup({
              capabilities = capabilities,
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
          ts_ls = function()
            lsp.ts_ls.setup({
              capabilities = capabilities,
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
                  preferences = {
                    importModuleSpecifier = "relative",
                  },
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
                  preferences = {
                    importModuleSpecifier = "relative",
                  },
                  referencesCodeLens = { enabled = false },
                  implementationsCodeLens = { enabled = false },
                },
              },
            })
          end,
          volar = function()
            lsp.volar.setup({
              capabilities = capabilities,
              filetypes = {
                "vue",
              },
              settings = {
                vue = {
                  complete = {
                    casing = {
                      props = "autoCamel",
                    },
                  },
                },
              },

              init_options = {
                vue = {
                  hybridMode = false,
                },
              },
            })
          end,
          cssls = function()
            lsp.cssls.setup({
              capabilities = capabilities,
              settings = {
                css = {
                  validate = true,
                  lint = {
                    unknownAtRules = "ignore",
                  },
                },
                scss = {
                  validate = true,
                  lint = {
                    unknownAtRules = "ignore",
                  },
                },
                less = {
                  validate = true,
                  lint = {
                    unknownAtRules = "ignore",
                  },
                },
              },
            })
          end,
          tailwindcss = function()
            lsp.tailwindcss.setup({
              capabilities = capabilities,
              settings = {
                tailwindCSS = {
                  experimental = {
                    classRegex = {
                      { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                      { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    },
                  },
                  classAttributes = {
                    "class",
                    "className",
                    "classNames",
                    "class:list",
                    "classList",
                    "ngClass",
                    "styles",
                    "style",
                  },
                  emmetCompletions = true,
                },
              },
            })
          end,
        },
      })

      -- builtin vim diagnostics options
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        float = {
          source = "always",
          severity_sort = true,
        },
        virtual_text = {
          spacing = 8,
          source = "always",
          prefix = "󰊠",
          severity_sort = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = utils.signs.ERROR,
            [vim.diagnostic.severity.WARN] = utils.signs.WARN,
            [vim.diagnostic.severity.HINT] = utils.signs.HINT,
            [vim.diagnostic.severity.INFO] = utils.signs.INFO,
          },
        },
      })

      get_keybinds_on_lsp()
      hide_virtual_in_insert()
    end,
  },
}
