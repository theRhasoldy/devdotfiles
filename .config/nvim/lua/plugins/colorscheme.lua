return {
  {
    -- "theRhasoldy/dahlia.nvim",
    -- name = "dahlia",
    -- enabled = true,
    -- lazy = false,
  },
  {
    "theRhasoldy/oxicarbon.nvim",
    -- dir = "~/Projects/Lua/oxicarbon.nvim/",
    -- dev = true,
    enabled = true,
    lazy = false,
    config = function()
      vim.cmd.colorscheme("oxicarbon")
    end,
  },
  {
    "theRhasoldy/oxocarbon.nvim",
    lazy = false,
    --[[ config = function()
      vim.cmd.colorscheme("oxocarbon")
    end, ]]
  },
}
