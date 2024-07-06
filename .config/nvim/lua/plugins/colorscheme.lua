return {
  "theRhasoldy/oxicarbon.nvim",
  -- dev = true,
  -- dir = "~/Projects/Lua/oxicarbon.nvim/",
  enabled = true,
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("oxicarbon")
  end,
}
