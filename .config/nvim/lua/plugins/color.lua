return {
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPost",
    ---@module "nvim-highlight-colors"
    opts = {
      render = "virtual",
      virtual_symbol_position = "eol",
      enable_tailwind = true,
      virtual_symbol = "",
    },
  },
}
