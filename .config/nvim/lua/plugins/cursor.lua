return {
  {
    "declancm/cinnamon.nvim",
    version = "*", -- use latest release
    opts = {
      keymaps = {
        basic = true,
        extra = true,
      },
      options = {
        mode = "cursor", -- Animate cursor and window scrolling for any movement
        step_size = {
          -- Number of cursor/window lines moved per step
          vertical = 1.5,
          -- Number of cursor/window columns moved per step
          horizontal = 4,
        },
      },
    },
    keys = function()
      local cinnamon = require("cinnamon")
      return {
        {
          "<c-d>",
          function()
            cinnamon.scroll("<C-d>")
          end,
          mode = "n",
        },
        {
          "<c-u>",
          function()
            cinnamon.scroll("<C-u>")
          end,
          mode = "n",
        },
        {
          "<c-f>",
          function()
            cinnamon.scroll("<C-f>")
          end,
          mode = "n",
        },
        {
          "<c-b>",
          function()
            cinnamon.scroll("<C-b>")
          end,
          mode = "n",
        },
        {
          "zz",
          function()
            cinnamon.scroll("zz")
          end,
          mode = "n",
        },
        {
          "zz",
          function()
            cinnamon.scroll("zz")
          end,
          mode = "n",
        },
        {
          "zt",
          function()
            cinnamon.scroll("zt")
          end,
          mode = "n",
        },
        {
          "zb",
          function()
            cinnamon.scroll("zb")
          end,
          mode = "n",
        },
        {
          "gg",
          function()
            cinnamon.scroll("gg")
          end,
          mode = "n",
        },
        {
          "G",
          function()
            cinnamon.scroll("G")
          end,
          mode = "n",
        },
      }
    end,
  },
}
