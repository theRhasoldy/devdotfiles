return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    ---@module "noice"
    ---@type NoiceConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      cmdline = {
        view = "cmdline",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = {
            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
            icon = "",
            lang = "lua",
          },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
          input = { view = "cmdline_input", icon = "󰥻" },
        },
      },
      routes = {
        {
          -- Macros message
          view = "cmdline",
          filter = { event = "msg_showmode" },
        },
        -- Supress annoying no info notifcation
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        },
      },
      hover = {
        enabled = true,
        silent = true,
      },
      lsp = {
        progress = {
          enabled = false,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
        },
      },
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    init = function()
      local lazy = require("lazy")

      vim.ui.select = function(...)
        lazy.load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end

      vim.ui.input = function(...)
        lazy.load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
    ---@module "dressing"
    ---@type dressing.InputConfig
    opts = {
      title_pos = "center",
      insert_only = false,
      border = "single",
      backend = { "telescope", "nui", "fzf_lua", "fzf", "builtin" },
      input = {
        enabled = true,
      },
      nui = {
        border = {
          style = "single",
        },
      },
      builtin = {
        border = "single",
      },
      select = {
        enabled = true,
        get_config = function(opts)
          if opts.kind == "codeaction" then
            return {
              backend = "builtin",
              builtin = {
                position = "10%",
                relative = "editor",
              },
            }
          end
        end,
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    ---@module "notify"
    ---@type notify.Config
    opts = {
      merge_duplicates = true,
      timeout = 2000,
      render = "compact",
      fps = 24,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      top_down = true,
    },
  },
}
