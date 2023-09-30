local path = vim.split(package.path, ";")

return {
  {
    "williamboman/mason.nvim",
    event = "BufReadPre",
    opts = {
      ui = {
        check_outdated_packages_on_open = true,
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
      -- disable lsp watcher. Too slow on linux
      local ok, wf = pcall(require, "vim.lsp._watchfiles")
      if ok then
        wf._watchfunc = function()
          return function() end
        end
      end
    end,
    config = function()
      -- Set Custom Icons
      local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl })
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local attach_settings = function(client)
        -- Disabled built-in lsp formatting, handled by null-ls
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      local defaults = {
        capabilities = capabilities,
        on_attach = attach_settings,
      }

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

      -- To instead override globally
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- Language server configs
      local lsp = require("lspconfig")

      lsp["lua_ls"].setup({
        defaults,
        single_file_support = true,
        settings = {
          Lua = {
            hint = { enable = true },
            workspace = {
              runtime = {
                version = "luajit",
                -- Setup your lua path
                path = path,
              },
              library = {
                vim.api.nvim_get_runtime_file("", true),
              },
              -- maxPreload = 2000,
              -- preloadFileSize = 50000,
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
        single_file_support = true,
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh" },
      })

      lsp["marksman"].setup(defaults)

      lsp["tsserver"].setup({
        defaults,
        disable_formatting = true,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
            referencesCodeLens = { enabled = true, showOnAllFunctions = true },
          },
          javascript = {
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
            referencesCodeLens = { enabled = true, showOnAllFunctions = true },
          },
        },
      })

      lsp["astro"].setup({
        defaults,
        format = {
          indentFrontmatter = true,
        },
      })

      lsp["html"].setup({
        defaults,
        single_file_support = true,
        filetypes = { "html" },
      })

      lsp["emmet_ls"].setup(defaults)

      lsp["yamlls"].setup(defaults)

      lsp["jsonls"].setup(defaults)

      lsp["cssls"].setup(defaults)

      vim.diagnostic.config({
        underline = false,
        update_in_insert = true,
        float = {
          source = "if_many",
        },
        virtual_text = {
          spacing = 4,
          -- source = "if_many",
          prefix = "󰊠 ",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          -- prefix = "icons",
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
        "gn",
        function()
          vim.diagnostic.goto_next()
        end,
      },
      {
        mode = "n",
        "gN",
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
        mode = "n",
        "gr",
        function()
          vim.lsp.buf.rename()
        end,
        desc = "Rename under cursor",
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
        timeout = 500, -- in milliseconds
        position = "eol", -- "right_align" | "overlay"
        separator = " | ", -- signs separator
        show_count = true, -- show the number of each action kind
        show_label = false, -- show the string returned by `label_fmt`
        update_on_insert = false, -- show and update signs in insert mode
        icons = {
          quickfix = " ",
          refactor = "󰖷 ",
          source = "󱍵 ",
        },
        highlights = { -- highlight groups
          quickfix = "Function",
          refactor = "Include",
          source = "Statement",
          label = "Comment",
        },
      },
      mappings = {
        -- The values can either be a string or a string tuple (with description)
        -- example: "<leader>aq" | { "<leader>aq", "Quickfix" }
        apply_first = nil, -- directly applies the first code action
        -- These are just basically `vim.lsp.buf.code_action` with the `apply` option with some filters
        -- If there's only one code action, it gets automatically applied.
        quickfix = nil, -- can be filtered with the `quickfix_filter` option bellow
        quickfix_next = nil, -- tries to fix the next diagnostic
        quickfix_prev = nil, -- tries to fix the previous diagnostic
        refactor = nil,
        refactor_inline = nil,
        refactor_extract = nil,
        refactor_rewrite = nil,
        source = nil,
        -- server-specific mappings, server_name = {...}
        -- This is a map of code actions prefixes and keys
        actions = {
          -- example:
          -- ["rust_analyzer"] = {
          --   ["Inline"] = "<leader>ai"
          --   ["Add braces"] = { "<leader>ab", "Add braces" }
          -- }
        },
      },
      -- This is used for filtering actions in the quickfix functions
      -- It's a map of diagnostic codes and the preferred action prefixes
      -- You can check the diagnostic codes by hovering on the diagnostic
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
