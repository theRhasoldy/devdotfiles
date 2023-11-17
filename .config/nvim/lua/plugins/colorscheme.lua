return {
  {
    "theRhasoldy/dahlia.nvim",
    lazy = false,
    name = "dahlia",
  },
  {
    "theRhasoldy/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oxocarbon")
    end,
  },
}
