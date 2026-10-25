---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      local constants = require("config.constants")
      local shared = require("util.shared")

      -- The only servers allowed to attach by themselves. Enabling is explicit
      -- so mason-lspconfig cannot pull in every installed server (vue, docker,
      -- mdx, ...) just because its binary happens to exist.
      ---@type table<string, vim.lsp.Config>
      local servers = {
        vtsls = {
          settings = {
            typescript = {
              suggest = { completeFunctionCalls = true },
              preferences = {
                preferTypeOnlyAutoImports = true,
              },
              tsserver = {
                watchOptions = {
                  excludeDirectories = { "**/dist/**", "**/build/**", "**/.turbo/**" },
                },
              },
            },
            javascript = {
              suggest = { completeFunctionCalls = true },
            },
          },
        },
        astro = {
          settings = {
            astro = { suggest = { completeFunctionCalls = true } },
          },
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              classFunctions = { "cn", "clsx", "cva", "twMerge" },
            },
          },
        },
        cssls = {
          settings = {
            -- The shipped at-rule data predates Tailwind v4 and flags every
            -- @theme/@utility/@apply/@source/... line. lspconfig's own
            -- `validate` defaults survive the merge.
            css = { lint = { unknownAtRules = "ignore" } },
          },
        },
        html = {
          settings = {
            -- nvim-ts-autotag already inserts the closing tag; the server would
            -- offer a second one as a snippet.
            html = { autoClosingTags = true },
          },
        },
        marksman = {
          init_options = {
            -- 2 = incremental. Upstream defaults to full sync (the whole buffer
            -- resent per keystroke) because it distrusts editors.
            preferredTextSyncKind = 2,
          },
        },
        -- `format = false`: conform owns formatting (prettierd), so eslint must
        -- not advertise `documentFormattingProvider`.
        eslint = {
          settings = {
            format = false,
          },
        },
        lua_ls = {},
        jsonls = {},
        yamlls = {},
        emmet_language_server = {},
        bashls = {},
        fish_lsp = {},
        sqls = {},
        postgres_lsp = {},
      }

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end
      vim.lsp.enable(vim.tbl_keys(servers))
      local function eol_swatch(bufnr, range, hex)
        local client = vim.lsp.get_clients({ bufnr = bufnr, name = "tailwindcss" })[1]
        if client == nil then
          return
        end
        local ns = vim.api.nvim_create_namespace("nvim.lsp.document_color:" .. client.id)
        vim.api.nvim_buf_set_extmark(bufnr, ns, range.start_row, range.start_col, {
          virt_text = { { constants.swatch, require("mini.hipatterns").compute_hex_color_group(hex, "fg") } },
          virt_text_pos = "eol",
          priority = 2000,
        })
      end

      vim.lsp.document_color.enable(true, nil, { style = eol_swatch })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("tailwind_color_swatch", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client ~= nil and client.name ~= "tailwindcss" then
            vim.lsp.document_color.enable(false, { bufnr = args.buf, client_id = client.id })
          end
        end,
      })

      -- TypeScript 7 native server (Mason `tsc`), opt-in. A TS buffer must be
      -- served by exactly one server, so the toggle detaches the other one for
      -- that buffer only; the detached client keeps serving its other buffers.

      ---Attach a registered config to one buffer, resolving its root dir first.
      ---@param name string
      ---@param bufnr integer
      local function attach(name, bufnr)
        local config = vim.deepcopy(vim.lsp.config[name])
        if config == nil or type(config.root_dir) ~= "function" then
          return
        end
        config.root_dir(bufnr, function(root)
          config.root_dir = root
          vim.lsp.start(config, { bufnr = bufnr })
        end)
      end

      local function tsgo_toggle()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.tbl_contains(shared.js_ts, vim.bo[bufnr].filetype) then
          vim.notify("TS7 toggle: only for JS/TS buffers", vim.log.levels.WARN)
          return
        end

        local native = vim.lsp.get_clients({ bufnr = bufnr, name = "tsc" })
        if #native > 0 then
          for _, client in ipairs(native) do
            vim.lsp.buf_detach_client(bufnr, client.id)
          end
          attach("vtsls", bufnr)
          vim.notify("TypeScript: vtsls", vim.log.levels.INFO)
          return
        end

        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "vtsls" })) do
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
        attach("tsc", bufnr)
        vim.notify("TypeScript: tsc (7.x native)", vim.log.levels.INFO)
      end

      vim.api.nvim_create_user_command("TsgoToggle", tsgo_toggle, {
        desc = "Toggle the TypeScript 7 native server for this buffer",
      })

      -- tsgo reads a literal `js/ts` section and supports `preferences.*` only
      -- (no `suggest.completeFunctionCalls`). Kept out of `servers` so
      -- `vim.lsp.enable` cannot attach it to every JS/TS buffer.
      vim.lsp.config("tsc", {
        settings = {
          ["js/ts"] = {
            preferences = { preferTypeOnlyAutoImports = true },
          },
        },
      })

      local pick_preview = require("util.pick")

      -- Neovim defaults the request to `includeDeclaration = true`, and
      -- mini.extra's picker always passes `nil` as the context, so the
      -- declaration would show up among the usages. Default it to false at the
      -- source (the default `grr` uses the same function) instead of forking
      -- the picker.
      local lsp_references = vim.lsp.buf.references
      vim.lsp.buf.references = function(context, opts)
        return lsp_references(context or { includeDeclaration = false }, opts)
      end

      local function pick_lsp(scope)
        return pick_preview.with_preview(function(opts)
          require("mini.extra").pickers.lsp({ scope = scope }, opts)
        end)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keys", { clear = true }),
        callback = function(args)
          vim.keymap.set("n", "grr", pick_lsp("references"), { buffer = args.buf, desc = "References" })
          vim.keymap.set("n", "gri", pick_lsp("implementation"), { buffer = args.buf, desc = "Implementations" })
          if vim.tbl_contains(shared.js_ts, vim.bo[args.buf].filetype) then
            vim.keymap.set("n", "<leader>cT", tsgo_toggle, {
              buffer = args.buf,
              desc = "Toggle TS7 native server",
            })
          end
        end,
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = "BufReadPre",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    ---@type MasonLspconfigSettings
    opts = {
      ensure_installed = {
        "lua_ls",
        "vtsls",
        "astro",
        "tailwindcss",
        "cssls",
        "html",
        "eslint",
        "jsonls",
        "yamlls",
        "marksman",
        "emmet_language_server",
        "bashls",
        "fish_lsp",
        "sqls",
        "postgres_lsp",
      },
      -- lsp.lua owns the enable list; auto-enabling would attach every
      -- installed server regardless of the stack this config targets.
      automatic_enable = false,
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    ---@type lazydev.Config
    opts = {},
  },
}
