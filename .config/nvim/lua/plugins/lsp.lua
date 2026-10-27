local constants = require("config.constants")

---EOL swatch for a Tailwind colour token; `mini.hipatterns` builds the group so
---the block follows the theme's foreground colour.
---@param bufnr integer
---@param range vim.Range
---@param hex string
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
      css = { lint = { unknownAtRules = "ignore" } },
    },
  },
  html = {
    settings = {
      html = { autoClosingTags = true },
    },
  },
  marksman = {
    init_options = {
      preferredTextSyncKind = 2,
    },
  },
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

---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      local shared = require("util.shared")

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end
      vim.lsp.enable(vim.tbl_keys(servers))

      -- Core paints document colours for every client that reports them. The
      -- swatch style is global, so Tailwind is the only client left enabled
      -- (the `LspAttach` hook below switches the rest off).
      vim.lsp.document_color.enable(true, nil, { style = eol_swatch })

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

      ---@param name string
      ---@param bufnr integer
      local function detach(name, bufnr)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = name })) do
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
      end

      local function tsgo_toggle()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.tbl_contains(shared.js_ts, vim.bo[bufnr].filetype) then
          vim.notify("TS7 toggle: only for JS/TS buffers", vim.log.levels.WARN)
          return
        end

        local native = #vim.lsp.get_clients({ bufnr = bufnr, name = "tsc" }) > 0
        detach(native and "tsc" or "vtsls", bufnr)
        attach(native and "vtsls" or "tsc", bufnr)
        vim.notify(native and "TypeScript: vtsls" or "TypeScript: tsc (7.x native)", vim.log.levels.INFO)
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

      -- Hover floats set `conceallevel = 2` but leave `concealcursor` empty, so a
      -- focused float still renders its first line raw — for a TS signature that
      -- line is the ```typescript fence, which then hides the signature itself.
      -- Conceal the cursor line too, leaving only content.
      local open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
        local bufnr, win = open_floating_preview(contents, syntax, opts)
        if win ~= nil and vim.bo[bufnr].filetype == "markdown" then
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = "n"
        end
        return bufnr, win
      end

      local function pick_lsp(scope)
        return pick_preview.with_preview(function(opts)
          require("mini.extra").pickers.lsp({ scope = scope }, opts)
        end)
      end

      ---Jump straight to a lone result, otherwise open the picker for the list.
      ---@param scope 'declaration'|'definition'|'implementation'|'references'|'type_definition'
      ---@return fun()
      local function lsp_goto(scope)
        return function()
          local opts = {
            on_list = function(what)
              if #what.items > 1 then
                return pick_lsp(scope)()
              end
              local tagname, from = vim.fn.expand("<cword>"), vim.fn.getpos(".")
              from[1] = vim.api.nvim_get_current_buf()
              vim.fn.settagstack(vim.fn.win_getid(), { items = { { tagname = tagname, from = from } } }, "t")
              -- mini.pick reads `path`; quickfix entries carry `filename`.
              local item = what.items[1]
              item.path = item.filename
              require("mini.pick").default_choose(item)
            end,
          }
          if scope == "references" then
            return vim.lsp.buf.references(nil, opts)
          end
          vim.lsp.buf[scope](opts)
        end
      end

      ---@param bufnr integer
      ---@return 'declaration'|'definition'
      local function declaration_scope(bufnr)
        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/declaration" })
        return next(clients) ~= nil and "declaration" or "definition"
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keys", { clear = true }),
        callback = function(args)
          -- One swatch style for all clients, so switch document colours off
          -- for everyone but Tailwind (cssls reports its own hex literals).
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name ~= "tailwindcss" then
            vim.lsp.document_color.enable(false, { bufnr = args.buf, client_id = client.id })
          end

          -- Vim's own `gd`/`gD` only search the current buffer. These ask the
          -- server and cross files; a multi-target result opens mini.pick.
          vim.keymap.set("n", "gd", function()
            lsp_goto(declaration_scope(args.buf))()
          end, { buffer = args.buf, desc = "Declaration" })
          vim.keymap.set("n", "gD", lsp_goto("definition"), { buffer = args.buf, desc = "Definition" })
          vim.keymap.set("n", "grt", lsp_goto("type_definition"), { buffer = args.buf, desc = "Type definition" })
          vim.keymap.set("n", "grr", lsp_goto("references"), { buffer = args.buf, desc = "References" })
          vim.keymap.set("n", "gri", lsp_goto("implementation"), { buffer = args.buf, desc = "Implementations" })
          vim.keymap.set("n", "gO", pick_lsp("document_symbol"), { buffer = args.buf, desc = "Document symbols" })
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
    -- Not just `cmd`: `setup()` is what puts Mason's bin dir on PATH, so the
    -- servers `vim.lsp.enable` starts would not be found without it.
    event = "BufReadPre",
    cmd = "Mason",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    ---@type MasonLspconfigSettings
    opts = {
      ensure_installed = vim.tbl_keys(servers),
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
