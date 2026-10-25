---@type LazySpec
return {
  {
    "Aejkatappaja/cendre",
    lazy = false,
    priority = 1000,
    config = function()
      ---@type CendreConfig
      local opts = {
        background = "medium", -- "hard" | "medium" | "soft"
        transparent = true,
        italic_virtual_text = true,
      }
      require("cendre").setup(opts)
      vim.cmd.colorscheme("cendre")
    end,
  },
}
