local constants = require("config.constants")

---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "prefer_rust" },

      keymap = {
        preset = "enter",
        ["<C-c>"] = { "show", "show_documentation", "hide_documentation" },
      },

      appearance = {
        -- Single-width glyphs keep the menu columns aligned.
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = { auto_show = false, window = { border = constants.border } },
        menu = { border = constants.border },
      },

      signature = {
        enabled = true,
        window = { border = constants.border },
      },

      cmdline = {
        keymap = { preset = "cmdline", ["<C-c>"] = { "show", "show_documentation", "hide_documentation" } },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = false },
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { inherit_defaults = true, "sqmeow" },
        },
        providers = {
          sqmeow = {
            name = "Sqmeow",
            module = "sqmeow.completion.blink",
          },
        },
      },
    },
    config = function(_, opts)
      -- Kind icons come from mini.icons so the menu speaks the same glyph
      -- vocabulary as mini.files and the statusline. Built here rather than in
      -- `opts` because mini.icons only joins the runtimepath once it loads.
      local icons = require("mini.icons")
      local kind_icons = {}
      for _, kind in ipairs(vim.lsp.protocol.CompletionItemKind) do
        kind_icons[kind] = icons.get("lsp", kind)
      end
      opts.appearance.kind_icons = kind_icons
      require("blink.cmp").setup(opts)
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<M-a>",
        accept_word = "<M-w>",
        clear_suggestion = "<M-e>",
      },
      log_level = "off",
    },
  },
}
