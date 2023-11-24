return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      cmdline = {
        view = "cmdline",
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
      lsp = {
        progress = {
          enabled = false,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = false, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      top_down = false,
      fps = 30,
      stages = "fade",
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = "",
      },
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "BufReadPre",
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
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
        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
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
}
