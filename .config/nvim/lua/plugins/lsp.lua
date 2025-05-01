local utils = require("config.utils")
local path = vim.split(package.path, ";")

-- global keybinds
local get_keybinds_on_lsp = function(event)
  local cinnamon_ok, cinnamon = pcall(require, "cinnamon")
  local telescope_ok, telescope = pcall(require, "telescope.builtin")

  if not cinnamon_ok or not telescope_ok then
    print("error loading deps")
    return
  end

  utils.map("n", "<Leader><Leader>", function()
    vim.diagnostic.open_float()
  end)

  utils.map("n", "[d", function()
    cinnamon.scroll(function()
      vim.diagnostic.jump({ float = true, count = -1 })
    end)
  end, { desc = "Previous diagnostic" })

  utils.map("n", "]d", function()
    cinnamon.scroll(function()
      vim.diagnostic.jump({ float = true, count = 1 })
    end)
  end, { desc = "Next diagnostic" })

  utils.map("n", "K", function()
    vim.lsp.buf.hover()
  end, { desc = "Hover doc" })

  utils.map("n", "gs", function()
    vim.lsp.buf.signature_help()
  end, { desc = "Signature help" })

  -- go to
  utils.map("n", "gd", function()
    vim.lsp.buf.definition()
  end, { desc = "Go to definition" })

  utils.map("n", "gD", function()
    vim.lsp.buf.declaration()
  end, { desc = "Go to declaration" })

  utils.map("n", "grr", function()
    telescope.lsp_references()
  end, { desc = "List references" })

  utils.map("n", "gi", function()
    vim.lsp.buf.implementation()
  end, { desc = "Go to implementation" })

  utils.map("n", "gt", function()
    vim.lsp.buf.type_definition()
  end, { desc = "Go to type definition" })

  -- format buffer
  utils.map({ "n", "x" }, "==", function()
    vim.lsp.buf.format({ async = true })
  end, { buffer = event.buf, desc = "Format buffer" })
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
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = {
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
          "sqls",
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
  opts = function()
    local ret = {
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = true,
        float = {
          source = "if_many",
        },
        virtual_text = {
          spacing = 10,
          source = "if_many",
          prefix = "󰊠",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = utils.signs.ERROR,
            [vim.diagnostic.severity.WARN] = utils.signs.WARN,
            [vim.diagnostic.severity.HINT] = utils.signs.HINT,
            [vim.diagnostic.severity.INFO] = utils.signs.INFO,
          },
        },
      },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      servers = {
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
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
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Replace",
              },
              format = {
                enable = true,
              },
              telemetry = {
                enable = false,
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
        ts_ls = {
          filetypes = {
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "javascript",
            "javascriptreact",
            "javascript.jsx",
          },
          handlers = {
            ["textDocument/publishDiagnostics"] = function(_, result, ctx)
              if result.diagnostics == nil then
                return
              end

              -- ignore some tsserver diagnostics
              local idx = 1
              while idx <= #result.diagnostics do
                local entry = result.diagnostics[idx]

                local formatter = require("format-ts-errors")[entry.code]
                entry.message = formatter and formatter(entry.message) or entry.message

                -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                if entry.code == 80001 then
                  -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
                  table.remove(result.diagnostics, idx)
                else
                  idx = idx + 1
                end
              end

              vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
            end,
          },
          settings = {
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              format = { enable = false },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
              suggest = {
                includeCompletionsForModuleExports = true,
                completeFunctionCalls = true,
              },
              referencesCodeLens = { enabled = false },
              implementationsCodeLens = { enabled = false },
              preferences = {
                importModuleSpecifier = "relative",
              },
            },

            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
              format = { enable = false },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
              suggest = {
                includeCompletionsForModuleExports = true,
                completeFunctionCalls = true,
              },
              referencesCodeLens = { enabled = false },
              implementationsCodeLens = { enabled = false },
              preferences = {
                importModuleSpecifier = "relative",
              },
            },
          },
        },
        volar = {
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
        },
        emmet_language_server = {
          init_options = {
            showAbbreviationSuggestions = true,
            showExpandedAbbreviation = "always",
            showSuggestionsAsSnippets = false,
          },
        },
        cssls = {
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
        },
        eslint = {
          settings = {
            eslint = {
              autoFixOnSave = true,
            },
          },
          root_dir = require("lspconfig").util.root_pattern(
            ".eslintrc.js",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            ".eslintrc.cjs",
            ".eslintrc.mjs",
            ".eslintrc",
            "eslint.config.js",
            "eslint.config.cjs",
            "eslint.config.mjs"
          ),
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                  {
                    "cva\\(((?:[^()]|\\([^()]*\\))*)\\)",
                    "[\"'`]([^\"'`]*).*?[\"'`]",
                  },
                  {
                    "cx\\(((?:[^()]|\\([^()]*\\))*)\\)",
                    "(?:'|\"|`)([^']*)(?:'|\"|`)",
                  },
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
        },
      },
      setup = {
        ["*"] = function(_, opts)
          opts.on_attach = function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          end
        end,
      },
    }
    return ret
  end,
  config = function(_, opts)
    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    local servers = opts.servers

    local cmp_capabilities = nil
    if pcall(require, "blink.cmp") then
      cmp_capabilities = require("blink.cmp").get_lsp_capabilities()
    end

    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

    local capabilities = vim.tbl_deep_extend(
      "force",
      lsp_capabilities or {},
      cmp_capabilities or {},
      opts.capabilities or {}
    )

    local function setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})
      if server_opts.enabled == false then
        return
      end

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          return
        end
      end
      require("lspconfig")[server].setup(server_opts)
    end

    local ok_mason, mason = pcall(require, "mason-lspconfig")

    if not ok_mason then
      print("error loading lsp config")
      return
    end

    mason.setup({
      handlers = { setup },
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = false,
    })

    -- attach these keybinds only if there is an active lsp server
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        get_keybinds_on_lsp(event)
        hide_virtual_in_insert()
      end,
    })
  end,
}
