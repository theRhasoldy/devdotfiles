return {
  {
    "theRhasoldy/dahlia.nvim",
    name = "dahlia",
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oxocarbon")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
      vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#121212" })
    end,
  },
}
