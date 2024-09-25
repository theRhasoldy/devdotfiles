return {
  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          agent = {
            adapter = "gemini",
          },
        },
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = os.getenv("GEMINI_API_KEY"),
              },
            })
          end,
        },
      })
    end,
  },
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    opts = {
      show_labels = false,
      max_lines = 1000,
    },
    keys = function()
      local neocodeium = require("neocodeium")
      return {
        {
          "<A-g>",
          function()
            neocodeium.accept()
          end,
          mode = "i",
        },
        {
          "<A-w>",
          function()
            neocodeium.accept_word()
          end,
          mode = "i",
        },
        {
          "<A-l>",
          function()
            neocodeium.accept_line()
          end,
          mode = "i",
        },
        {
          "<A-n>",
          function()
            neocodeium.cycle_or_complete()
          end,
          mode = "i",
        },
        {
          "<A-p>",
          function()
            neocodeium.cycle_or_complete(-1)
          end,
          mode = "i",
        },
        {
          "<A-c>",
          function()
            neocodeium.clear()
          end,
          mode = "i",
        },
      }
    end,
  },
}
