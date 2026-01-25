return {
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    ---@module "neocodeium.options"
    opts = {
      silent = true,
      show_labels = false,
      max_lines = 1000,
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        telescope_prompt = false,
      },
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
