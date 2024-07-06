local symbols = {
  Text = "󰚞",
  Method = "󰆩",
  Function = "󰊕",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "󱉸",
  Value = "󱢏",
  Enum = "",
  Keyword = "",
  Snippet = "󰆐",
  Color = "󰌁",
  File = "󰈔",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "󱌣",
  TypeParameter = "󰉺",
}

return {
  "MunifTanjim/nui.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
  {
    "onsails/lspkind.nvim",
    event = "BufReadPre",
    config = function()
      require("lspkind").init({
        mode = "symbol_text",
        preset = "codicons",
        symbol_map = symbols,
      })
    end,
  },
}
