local path = vim.split(package.path, ";")

local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }

local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}

return {
  {
    "williamboman/mason.nvim",
    event = "BufReadPre",
    opts = {
      ui = {
        check_outdated_packages_on_open = false,
        border = "single",
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
    event = "BufReadPre",
    init = function()
      local ok, wf = pcall(require, "vim.lsp._watchfiles")
      if ok then
        wf._watchfunc = function()
          return function() end
        end
      end
    end,

    config = function()
      local lsp = require("lspconfig")
      local lsp_defaults = lsp.util.default_config

      -- LSP Capabilities
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Extend default lsp config
      local attach_settings = function(client)
        -- Handled by none ls
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = true
      end

      lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_capabilities, cmp_capabilities)
      lsp_defaults.on_attach = attach_settings

      -- Set Custom Icons
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
      end

      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- lsp setup
      lsp["lua_ls"].setup({
        lsp_defaults,
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

      lsp["bashls"].setup({
        lsp_defaults,
        single_file_support = true,
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh" },
      })

      lsp["eslint"].setup(lsp_defaults)

      lsp["tsserver"].setup({
        lsp_defaults,
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

      lsp["volar"].setup({
        lsp_defaults,
        filetypes = { "vue" },
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

      lsp["astro"].setup({
        lsp_defaults,
        format = {
          indentFrontmatter = true,
        },
      })

      lsp["mdx_analyzer"].setup({
        lsp_defaults,
        filetypes = { "mdx" },
      })

      lsp["marksman"].setup(lsp_defaults)

      lsp["html"].setup({
        lsp_defaults,
        single_file_support = true,
        filetypes = { "html" },
      })

      lsp["emmet_language_server"].setup({
        lsp_defaults.capabilities,
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      })

      lsp["yamlls"].setup(lsp_defaults)

      lsp["jsonls"].setup(lsp_defaults)

      lsp["cssls"].setup({
        lsp_defaults,
        settings = {
          css = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
          scss = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
          less = { validate = true, lint = {
            unknownAtRules = "ignore",
          } },
        },
      })

      lsp["tailwindcss"].setup({
        lsp_defaults,
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

      vim.diagnostic.config({
        underline = false,
        update_in_insert = true,
        float = {
          source = "always",
          severity_sort = true,
        },
        virtual_text = {
          spacing = 24,
          source = "always",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          prefix = "󰊠 ",
          severity_sort = true,
        },
      })
    end,
    keys = {
      {
        mode = "n",
        "gh",
        function()
          vim.lsp.inlay_hint(0, nil)
        end,
        desc = "Toggle inlay hints",
      },
      {
        mode = "n",
        "<Leader><Leader>",
        function()
          vim.diagnostic.open_float()
        end,
        desc = "Line Diagnostics",
      },
      {
        mode = "n",
        "gtd",
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end,
        desc = "Go to definition",
      },
      {
        mode = "n",
        "gd",
        function()
          vim.lsp.buf.hover()
        end,
        desc = "Hover details",
      },
      {
        mode = "n",
        "d]",
        function()
          vim.diagnostic.goto_next()
        end,
      },
      {
        mode = "n",
        "d[",
        function()
          vim.diagnostic.goto_prev()
        end,
      },
      {
        mode = { "n", "v" },
        "ga",
        function()
          vim.lsp.buf.code_action()
        end,
        desc = "Code actions provided by LSP",
      },
      {
        mode = "i",
        "<C-k>",
        function()
          vim.lsp.buf.signature_help()
        end,
        desc = "Signature Help",
      },
      {
        mode = "n",
        "gR",
        function()
          vim.lsp.buf.references()
        end,
        desc = "Check references under cursor",
      },
    },
  },
  {
    "luckasRanarison/clear-action.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        enable = true,
        timeout = 1000, -- in milliseconds
        position = "eol", -- "right_align" | "overlay"
        separator = " | ", -- signs separator
        show_count = true, -- show the number of each action kind
        show_label = false, -- show the string returned by `label_fmt`
        update_on_insert = false, -- show and update signs in insert mode
        icons = {
          quickfix = "󰖷 ",
          refactor = " ",
          source = "󱍵 ",
          combined = "󰌵 ", -- used when combine is set to true or as a fallback when there is no action kind
        },
        highlights = { -- highlight groups
          quickfix = "Function",
          refactor = "Include",
          source = "Statement",
          label = "Comment",
          combined = "Variable",
        },
      },
      mappings = {
        -- The values can either be a string or a string tuple (with description)
        -- example: "<leader>aq" | { "<leader>aq", "Quickfix" }
        apply_first = nil, -- directly applies the first code action
        quickfix = nil, -- can be filtered with the `quickfix_filter` option bellow
        refactor = nil,
        refactor_inline = nil,
        refactor_extract = nil,
        refactor_rewrite = nil,
        source = nil,
        actions = {
          -- example:
          -- ["rust_analyzer"] = {
          --   ["Inline"] = "<leader>ai"
          --   ["Add braces"] = { "<leader>ab", "Add braces" }
          -- }
        },
      },
      quickfix_filters = {
        -- example:
        -- ["rust_analyzer"] = {
        --   ["E0433"] = "Import",
        -- },
        -- ["lua_ls"] = {
        --   ["unused-local"] = "Disable diagnostics on this line",
        -- },
      },
    },
  },
}
