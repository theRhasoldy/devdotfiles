-- The build step downloads the Rust engine.
---@type LazySpec
return {
  {
    "2giosangmitom/sqmeow.nvim",
    version = "*",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "sql",
    cmd = "Sqmeow",
    keys = {
      { "<leader>db", "<cmd>Sqmeow<cr>", desc = "SQL: open database client" },
    },
    build = function()
      require("sqmeow").install()
    end,
    opts = {},
  },
}
