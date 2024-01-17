return {
  {
    "theRhasoldy/dahlia.nvim",
    name = "dahlia",
  },
  {
    "theRhasoldy/oxocarbon.nvim",
    lazy = false,
    config = function()
      vim.cmd.colorscheme("oxocarbon")
    end,
  },
}
