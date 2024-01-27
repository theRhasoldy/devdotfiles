return {
  {
    "theRhasoldy/dahlia.nvim",
    name = "dahlia",
    enabled = false,
  },
  {
    "theRhasoldy/oxocarbon.nvim",
    lazy = false,
    config = function()
      vim.cmd.colorscheme("oxocarbon")
    end,
  },
}
