return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if vim.lsp.document_color then
            vim.lsp.document_color.enable(false, { bufnr = args.buf })
          end
        end,
      })
    end,
    opts = {
      diagnostics = {
        underline = true,
        -- don't fight the linters while typing; refresh on InsertLeave
        update_in_insert = false,
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
        -- only used when vim.g.lazyvim_ts_lsp is switched back to "vtsls"
        vtsls = {
          -- kept so extras that append to vtsls.filetypes (vue, astro) don't break
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            typescript = {
              tsserver = {
                -- stop tsserver from watching huge generated/dependency trees
                watchOptions = {
                  excludeDirectories = {
                    "**/node_modules/**",
                    "**/.next/**",
                    "**/dist/**",
                    "**/build/**",
                    "**/.turbo/**",
                  },
                },
              },
            },
          },
        },
        eslint = {
          settings = {
            -- help eslint find the eslintrc when it's placed in a subdirectory
            workingDirectories = { mode = "auto" },
            -- NOTE: `run = "onSave"` is ignored by vscode-langservers-extracted 4.10.0
            -- (it lints on every didChange regardless), so it's not set here.
            -- formatting is handled by conform (prettierd); don't lint + format twice
            format = false,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    -- Route each project to the right TypeScript server:
    --  * TS 7 (`tsc`)  -> only when the project's tsconfig no longer uses `baseUrl`
    --    (TS 7 removed it) or when the repo opts in with a `.tsgo` marker file.
    --  * vtsls         -> everything else, using the workspace TypeScript version
    --    (vtsls.autoUseWorkspaceTsdk), so old TS versions keep working.
    -- Force either way per repo with `.tsgo` / `.tsvtsls` in the project root.
    opts = function(_, opts)
      local function nearest_tsconfig(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return nil
        end
        return vim.fs.find({ "tsconfig.json", "jsconfig.json" }, {
          upward = true,
          type = "file",
          path = vim.fs.dirname(name),
        })[1]
      end

      --- Generated / dependency trees. Never start a project server from a buffer
      local generated = { "/.next/", "/node_modules/", "/dist/", "/build/", "/.turbo/", "/.intlayer/" }
      ---@param bufnr integer
      ---@return boolean
      local function is_generated(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        for _, dir in ipairs(generated) do
          if name:find(dir, 1, true) then
            return true
          end
        end
        return false
      end

      local cache = {}
      --- Per-buffer decision, cached by tsconfig path (monorepos have several).
      ---@param bufnr integer
      ---@param root string
      local function use_ts7(bufnr, root)
        local cfg = nearest_tsconfig(bufnr)
        local key = cfg or root
        if cache[key] ~= nil then
          return cache[key]
        end
        local res
        if vim.uv.fs_stat(root .. "/.tsvtsls") then
          res = false
        elseif vim.uv.fs_stat(root .. "/.tsgo") then
          res = true
        elseif not cfg then
          -- no tsconfig/jsconfig -> nothing TS 7 can do here
          res = false
        else
          -- NOTE: only the nearest config is inspected; a `baseUrl` inherited
          -- through `extends` is not detected (drop a `.tsvtsls` in that repo).
          local lines = vim.fn.readfile(cfg, "", 200)
          res = not table.concat(lines, "\n"):find('"baseUrl"', 1, true)
        end
        cache[key] = res
        return res
      end

      opts.servers.tsc = vim.tbl_deep_extend("force", opts.servers.tsc or {}, {
        enabled = true,
        settings = {
          ["js/ts"] = {
            inlayHints = {
              parameterNames = { enabled = "none" },
              parameterTypes = { enabled = false },
              variableTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = false },
            },
            referencesCodeLens = { enabled = false },
            implementationsCodeLens = { enabled = false },
          },
        },
        -- Batch `didChange` notifications: typing (or scrolling while a change is
        -- pending) no longer triggers one project-wide check per keystroke.
        flags = { debounce_text_changes = 300 },
        root_dir = function(bufnr, on_dir)
          if is_generated(bufnr) then
            return
          end
          local root =
            vim.fs.root(bufnr, { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" })
          if root and use_ts7(bufnr, root) then
            on_dir(root)
          end
        end,
      })

      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        enabled = true,
        flags = { debounce_text_changes = 300 },
        root_dir = function(bufnr, on_dir)
          if is_generated(bufnr) then
            return
          end
          if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
            return
          end
          local root = vim.fs.root(
            bufnr,
            { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" }
          ) or vim.fn.getcwd()
          if not use_ts7(bufnr, root) then
            on_dir(root)
          end
        end,
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    -- native TypeScript 7 compiler, used as the TS language server (see options.lua)
    opts = { ensure_installed = { "tsc" } },
  },
}
